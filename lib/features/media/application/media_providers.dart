import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/features/media/application/media_cache_lifecycle.dart';
import 'package:raha_move/features/media/application/media_preparation_service.dart';
import 'package:raha_move/features/media/application/routine_media_playback_coordinator.dart';
import 'package:raha_move/features/media/data/connectivity_media_network_status.dart';
import 'package:raha_move/features/media/data/drift_media_cache_index.dart';
import 'package:raha_move/features/media/data/file_system_media_file_store.dart';
import 'package:raha_move/features/media/data/http_media_download_client.dart';
import 'package:raha_move/features/media/data/supabase_trusted_media_resolver.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'media_providers.g.dart';

/// Authentication owns this value and must override it with the current
/// anonymous/authenticated Supabase user plus the server entitlement snapshot.
@Riverpod(keepAlive: true)
MediaAccessScope? mediaAccessScope(Ref ref) {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return userId == null ? null : MediaAccessScope(ownerId: userId);
  } catch (_) {
    return null;
  }
}

@Riverpod(keepAlive: true)
MediaCacheIndex mediaCacheIndex(Ref ref) =>
    DriftMediaCacheIndex(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
Future<MediaFileStore> mediaFileStore(Ref ref) async {
  final cacheRoot = await getApplicationCacheDirectory();
  return FileSystemMediaFileStore(
    Directory('${cacheRoot.path}${Platform.pathSeparator}raha-media-v2'),
  );
}

@Riverpod(keepAlive: true)
MediaNetworkStatus mediaNetworkStatus(Ref ref) =>
    ConnectivityMediaNetworkStatus();

@Riverpod(keepAlive: true)
MediaDownloadClient mediaDownloadClient(Ref ref) {
  final client = HttpMediaDownloadClient();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
TrustedMediaResolver trustedMediaResolver(Ref ref) {
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {
    // The resolver remains fail-closed while backend bootstrap is unavailable.
  }
  if (client == null) return const _UnavailableTrustedMediaResolver();
  return SupabaseTrustedMediaResolver(
    gateway: SupabaseMediaAuthorizationGateway(client),
    clock: DateTime.now,
  );
}

@riverpod
Future<MediaCacheLifecycle> mediaCacheLifecycle(Ref ref) async =>
    MediaCacheLifecycle(
      cache: ref.watch(mediaCacheIndexProvider),
      files: await ref.watch(mediaFileStoreProvider.future),
    );

@riverpod
Future<MediaPreparationService?> mediaPreparationService(Ref ref) async {
  final accessScope = ref.watch(mediaAccessScopeProvider);
  if (accessScope == null) return null;
  return MediaPreparationService(
    resolver: ref.watch(trustedMediaResolverProvider),
    downloader: ref.watch(mediaDownloadClientProvider),
    files: await ref.watch(mediaFileStoreProvider.future),
    cache: ref.watch(mediaCacheIndexProvider),
    network: ref.watch(mediaNetworkStatusProvider),
    accessScope: accessScope,
    clock: DateTime.now,
  );
}

@riverpod
Future<RoutineMediaPlaybackCoordinator?> routineMediaPlaybackCoordinator(
  Ref ref,
) async {
  final preparation = await ref.watch(mediaPreparationServiceProvider.future);
  return preparation == null
      ? null
      : RoutineMediaPlaybackCoordinator(preparation);
}

final class _UnavailableTrustedMediaResolver implements TrustedMediaResolver {
  const _UnavailableTrustedMediaResolver();

  @override
  Future<EphemeralMediaUrl> resolve(MediaAuthorizationRequest request) =>
      Future.error(const MediaAuthorizationException('resolver_unconfigured'));
}
