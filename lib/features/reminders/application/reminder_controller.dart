import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/application/auth_controller.dart';
import '../domain/reminder_repository.dart';
import '../domain/reminder_schedule.dart';
import 'reminder_providers.dart';

part 'reminder_controller.g.dart';

final class ReminderSettingsState {
  const ReminderSettingsState({
    required this.schedule,
    required this.permission,
    this.schedulingFailed = false,
  });
  final ReminderSchedule? schedule;
  final ReminderPermission permission;
  final bool schedulingFailed;

  ReminderSettingsState copyWith({
    ReminderSchedule? schedule,
    ReminderPermission? permission,
    bool? schedulingFailed,
  }) => ReminderSettingsState(
    schedule: schedule ?? this.schedule,
    permission: permission ?? this.permission,
    schedulingFailed: schedulingFailed ?? this.schedulingFailed,
  );
}

@Riverpod(keepAlive: true)
class ReminderController extends _$ReminderController {
  String get _userId =>
      ref.read(authControllerProvider).requireValue.activeUserId!;
  ReminderRepository get _repository => ref.read(reminderRepositoryProvider);
  ReminderPlatform get _platform => ref.read(reminderPlatformProvider);

  @override
  Future<ReminderSettingsState> build() async {
    final user = await ref.watch(authControllerProvider.future);
    final systemStatus = await _platform.permissionStatus();
    final permissionStore = ref.read(reminderPermissionStoreProvider);
    final recordedDenial = await permissionStore.wasDenied(user.activeUserId!);
    final permission = switch (systemStatus) {
      ReminderPermission.granted => ReminderPermission.granted,
      ReminderPermission.denied => ReminderPermission.denied,
      ReminderPermission.notDetermined when recordedDenial =>
        ReminderPermission.denied,
      ReminderPermission.notDetermined => ReminderPermission.notDetermined,
    };
    if (permission == ReminderPermission.granted) {
      await ref
          .read(reminderPermissionStoreProvider)
          .clearDenied(user.activeUserId!);
    } else if (systemStatus == ReminderPermission.denied) {
      await permissionStore.recordDenied(user.activeUserId!);
    }
    return ReminderSettingsState(
      schedule: await _repository.read(user.activeUserId!),
      permission: permission,
    );
  }

  Future<void> save({
    required int hour,
    required int minute,
    required Set<int> days,
    required ReminderNotificationContent content,
  }) async {
    final timezone = await _platform.currentIanaTimezone();
    final existing = state.requireValue.schedule;
    final schedule =
        (existing ??
                ReminderSchedule.dailyAtSix(
                  id: 'reminder-$_userId',
                  userId: _userId,
                  timezone: timezone,
                ))
            .copyWith(
              hour: hour,
              minute: minute,
              daysOfWeek: days,
              timezone: timezone,
              enabled: true,
            );
    await _repository.save(
      schedule,
    ); // local choice wins even if native scheduling fails
    var permission = state.requireValue.permission;
    if (permission == ReminderPermission.notDetermined) {
      final granted = await _platform.requestPermission();
      if (!granted) {
        await ref.read(reminderPermissionStoreProvider).recordDenied(_userId);
        state = AsyncData(
          ReminderSettingsState(
            schedule: schedule,
            permission: ReminderPermission.denied,
          ),
        );
        return;
      }
      await ref.read(reminderPermissionStoreProvider).clearDenied(_userId);
      permission = ReminderPermission.granted;
    }
    try {
      await _platform.schedule(schedule, content);
      state = AsyncData(
        ReminderSettingsState(schedule: schedule, permission: permission),
      );
    } catch (_) {
      state = AsyncData(
        ReminderSettingsState(
          schedule: schedule,
          permission: permission,
          schedulingFailed: true,
        ),
      );
    }
  }

  Future<void> pause() async {
    final schedule = state.requireValue.schedule;
    if (schedule == null) {
      return;
    }
    final paused = schedule.copyWith(enabled: false);
    await _repository.save(paused);
    try {
      await ref
          .read(reminderCancellationProvider)
          .cancelScheduleId(schedule.id);
      state = AsyncData(state.requireValue.copyWith(schedule: paused));
    } catch (_) {
      state = AsyncData(
        state.requireValue.copyWith(schedule: paused, schedulingFailed: true),
      );
    }
  }

  Future<void> disable() async {
    final schedule = state.requireValue.schedule;
    if (schedule == null) return;
    // Persist disabled first, retaining the deterministic identity for retries.
    final disabled = schedule.copyWith(enabled: false);
    await _repository.save(disabled);
    try {
      await ref
          .read(reminderCancellationProvider)
          .cancelScheduleId(schedule.id);
      await _repository.remove(_userId);
      state = AsyncData(state.requireValue.copyWith(schedule: null));
    } catch (_) {
      state = AsyncData(
        state.requireValue.copyWith(schedule: disabled, schedulingFailed: true),
      );
    }
  }

  /// Called on opening and resume. It never asks for native permission.
  Future<void> reconcile(ReminderNotificationContent content) async {
    final userId = (await ref.read(authControllerProvider.future)).activeUserId;
    if (userId == null) return;
    try {
      await ref
          .read(reminderLifecycleServiceProvider)
          .reconcile(userId: userId, content: content);
      final updated = await _repository.read(userId);
      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(schedule: updated, schedulingFailed: false),
        );
      }
    } catch (_) {
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(schedulingFailed: true));
      }
    }
  }

  Future<void> openSettings() => _platform.openSettings();
}
