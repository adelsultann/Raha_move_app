import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/bootstrap/catalog_bootstrap_providers.dart';
import '../../authentication/application/auth_controller.dart';
import '../../authentication/application/auth_providers.dart';
import '../../media/application/media_providers.dart';
import '../../sync/application/sync_providers.dart';
import '../../reminders/application/reminder_providers.dart';
import '../data/drift_profile_repository.dart';
import '../data/rpc_account_deletion_action.dart';
import '../domain/account_deletion_action.dart';
import '../domain/profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    DriftProfileRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
AccountDeletionAction accountDeletionAction(Ref ref) =>
    RpcAccountDeletionAction(
      ref.watch(syncRpcGatewayProvider),
      ref.watch(recentSignInTrackerProvider),
      () => ref.read(authControllerProvider).value?.activeUserId,
      () => ref.read(authControllerProvider).value?.mediaOwnerId,
      DriftAccountDeletionCleanup(
        ref.watch(appDatabaseProvider),
        ref.watch(authRepositoryProvider),
        ref.watch(guestIdentityStoreProvider),
        () => ref.read(mediaCacheLifecycleProvider.future),
        cancelReminders: (userId) =>
            ref.read(reminderCancellationProvider).cancelForUser(userId),
      ),
    );

@Riverpod(keepAlive: true)
Future<AccountDeletionCleanupResult> accountDeletionRecovery(Ref ref) =>
    DriftAccountDeletionCleanup(
      ref.watch(appDatabaseProvider),
      ref.watch(authRepositoryProvider),
      ref.watch(guestIdentityStoreProvider),
      () => ref.read(mediaCacheLifecycleProvider.future),
      cancelReminders: (userId) =>
          ref.read(reminderCancellationProvider).cancelForUser(userId),
    ).recoverPending();
