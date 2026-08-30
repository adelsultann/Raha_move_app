import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/features/media/application/media_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wires Supabase session changes to the fail-closed private-cache purge.
class MediaCacheAuthObserver extends ConsumerStatefulWidget {
  const MediaCacheAuthObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MediaCacheAuthObserver> createState() =>
      _MediaCacheAuthObserverState();
}

class _MediaCacheAuthObserverState
    extends ConsumerState<MediaCacheAuthObserver> {
  StreamSubscription<AuthState>? _subscription;
  String? _previousOwnerId;

  @override
  void initState() {
    super.initState();
    unawaited(_bind());
  }

  Future<void> _bind() async {
    SupabaseClient? client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      // Offline/unconfigured builds still purge any remote owner partitions.
    }
    _previousOwnerId = client?.auth.currentUser?.id;
    await _reconcile(_previousOwnerId);
    if (client == null || !mounted) return;
    _subscription = client.auth.onAuthStateChange.listen((state) {
      unawaited(_sessionChanged(state.session?.user.id));
    });
  }

  Future<void> _sessionChanged(String? currentOwnerId) async {
    final previous = _previousOwnerId;
    try {
      final lifecycle = await ref.read(mediaCacheLifecycleProvider.future);
      await lifecycle.onSessionChanged(
        previousOwnerId: previous,
        currentOwnerId: currentOwnerId,
      );
      await lifecycle.reconcileCurrentOwner(currentOwnerId);
      ref.invalidate(mediaAccessScopeProvider);
      _previousOwnerId = currentOwnerId;
    } catch (_) {
      // Do not advance the remembered owner. The next auth event/startup will
      // retry; owner-partitioned lookups keep the new account fail-closed.
    }
  }

  Future<void> _reconcile(String? currentOwnerId) async {
    try {
      final lifecycle = await ref.read(mediaCacheLifecycleProvider.future);
      await lifecycle.reconcileCurrentOwner(currentOwnerId);
    } catch (_) {
      // Cache metadata remains partitioned and a later startup retries purge.
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
