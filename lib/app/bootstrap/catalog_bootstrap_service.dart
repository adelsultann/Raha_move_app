import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/content_release_contract.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/drift_content_release_repository.dart';

/// Where the active catalog came from after a bootstrap/sync pass.
enum CatalogBootstrapSource { bundled, server, existing }

/// The outcome of one bootstrap/sync pass. [errorCode] is a stable,
/// language-neutral diagnostic when the pass failed but the already-applied
/// catalog (bundled or previously synced) remains available for offline use.
final class CatalogBootstrapResult {
  const CatalogBootstrapResult({
    required this.currentReleaseId,
    required this.source,
    this.errorCode,
  });

  final String currentReleaseId;
  final CatalogBootstrapSource source;
  final String? errorCode;

  bool get isClean => errorCode == null;
}

/// Application-owned orchestration for making the local catalog available.
///
/// On first launch it applies the bundled starter catalog, then it requests
/// the next release from an injectable [ContentReleaseSource]. Every failure
/// (bundled load/apply or remote sync) is turned into a recoverable result
/// carrying [CatalogBootstrapResult.errorCode]; the repository applies releases
/// atomically, so the previously applied catalog is never discarded. Callers
/// re-run [run] to retry.
final class CatalogBootstrapService {
  CatalogBootstrapService({
    required this._repository,
    required this._starterContent,
    required this._source,
    required this._appVersion,
  });

  final ContentReleaseRepository _repository;
  final BundledStarterContent _starterContent;
  final ContentReleaseSource _source;
  final String _appVersion;

  Future<CatalogBootstrapResult> run() async {
    var source = CatalogBootstrapSource.existing;
    String? errorCode;

    // 1. Bundled starter first so a fresh install works offline.
    try {
      if (!await _repository.hasCurrentRelease()) {
        final starter = await _starterContent.load();
        await _repository.applyRelease(starter, appVersion: _appVersion);
        source = CatalogBootstrapSource.bundled;
      }
    } on ContentReleaseException catch (error) {
      errorCode = error.code;
    } catch (_) {
      errorCode = 'bootstrap_failed';
    }

    // 2. Attempt a server sync; only when the bundled step succeeded. A sync
    // failure is a soft, offline-fallback state that keeps the local catalog.
    if (errorCode == null) {
      try {
        final currentId = await _repository.currentReleaseId();
        final next = await _source.fetchNextRelease(
          currentReleaseId: currentId ?? '0',
          appVersion: _appVersion,
        );
        if (next != null) {
          await _repository.applyRelease(next, appVersion: _appVersion);
          source = CatalogBootstrapSource.server;
        }
      } on ContentReleaseException catch (error) {
        errorCode = error.code;
      } catch (_) {
        errorCode = 'sync_unavailable';
      }
    }

    return CatalogBootstrapResult(
      currentReleaseId: (await _repository.currentReleaseId()) ?? '',
      source: source,
      errorCode: errorCode,
    );
  }
}
