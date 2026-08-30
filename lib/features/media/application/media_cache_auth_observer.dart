import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/media/application/media_providers.dart';

/// Wires authentication identity changes to the fail-closed private-cache
/// purge. It reacts to the auth controller's media owner (the Supabase uid when
/// anonymous/authenticated, null while guest/offline) rather than listening to
/// the raw Supabase auth stream, and preserves the startup reconcile behavior.
class MediaCacheAuthObserver extends ConsumerStatefulWidget {
  const MediaCacheAuthObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MediaCacheAuthObserver> createState() =>
      _MediaCacheAuthObserverState();
}

class _MediaCacheAuthObserverState
    extends ConsumerState<MediaCacheAuthObserver> {
  String? _previousOwnerId;

  @override
  void initState() {
    super.initState();
    // Startup reconcile: remove partitions that do not belong to the current
    // owner (including every remote partition while still signed out).
    _previousOwnerId = ref.read(authControllerProvider).value?.mediaOwnerId;
    unawaited(_reconcile(_previousOwnerId));
    ref.listenManual(authControllerProvider, (previous, next) {
      final previousOwner = previous?.value?.mediaOwnerId;
      final nextOwner = next.value?.mediaOwnerId;
      unawaited(_ownerChanged(previousOwner, nextOwner));
    });
  }

  Future<void> _ownerChanged(
    String? previousOwner,
    String? currentOwner,
  ) async {
    final previous = _previousOwnerId;
    try {
      final lifecycle = await ref.read(mediaCacheLifecycleProvider.future);
      await lifecycle.onSessionChanged(
        previousOwnerId: previous,
        currentOwnerId: currentOwner,
      );
      await lifecycle.reconcileCurrentOwner(currentOwner);
      _previousOwnerId = currentOwner;
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
  Widget build(BuildContext context) => widget.child;
}
