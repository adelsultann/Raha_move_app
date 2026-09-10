import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/bootstrap/catalog_bootstrap_providers.dart';
import '../data/drift_reminder_repository.dart';
import '../data/flutter_local_reminder_platform.dart';
import '../data/secure_reminder_permission_store.dart';
import '../domain/reminder_repository.dart';
import 'reminder_cancellation.dart';
import 'reminder_lifecycle_service.dart';

part 'reminder_providers.g.dart';

@Riverpod(keepAlive: true)
ReminderRepository reminderRepository(Ref ref) =>
    DriftReminderRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ReminderPermissionStore reminderPermissionStore(Ref ref) =>
    SecureReminderPermissionStore();

@Riverpod(keepAlive: true)
ReminderPlatform reminderPlatform(Ref ref) => FlutterLocalReminderPlatform();

@Riverpod(keepAlive: true)
ReminderCancellation reminderCancellation(Ref ref) => ReminderCancellation(
  ref.watch(reminderRepositoryProvider),
  ref.watch(reminderPlatformProvider),
);

@Riverpod(keepAlive: true)
ReminderLifecycleService reminderLifecycleService(Ref ref) =>
    ReminderLifecycleService(
      ref.watch(reminderRepositoryProvider),
      ref.watch(reminderPlatformProvider),
    );
