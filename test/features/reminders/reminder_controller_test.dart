import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';
import 'package:raha_move/features/reminders/application/reminder_controller.dart';
import 'package:raha_move/features/reminders/application/reminder_lifecycle_service.dart';
import 'package:raha_move/features/reminders/application/reminder_providers.dart';
import 'package:raha_move/features/reminders/domain/reminder_repository.dart';
import 'package:raha_move/features/reminders/domain/reminder_schedule.dart';

void main() {
  test('denial saves local choice and never re-prompts', () async {
    final platform = _Platform(requestResult: false);
    final store = _Store();
    final repository = _Repository();
    final container = _container(repository, platform, store);
    addTearDown(container.dispose);
    await container.read(reminderControllerProvider.future);

    await container
        .read(reminderControllerProvider.notifier)
        .save(
          hour: 18,
          minute: 0,
          days: {1, 2, 3, 4, 5, 6, 7},
          content: _content,
        );
    await container
        .read(reminderControllerProvider.notifier)
        .save(
          hour: 19,
          minute: 0,
          days: {1, 2, 3, 4, 5, 6, 7},
          content: _content,
        );

    expect(platform.requestCalls, 1);
    expect(store.denied, isTrue);
    expect(repository.value?.hour, 19);
    expect(
      container.read(reminderControllerProvider).requireValue.permission,
      ReminderPermission.denied,
    );
  });

  test(
    'recorded denial survives controller recreation until settings grants it',
    () async {
      final platform = _Platform(requestResult: true);
      final store = _Store()..denied = true;
      final repository = _Repository();
      final first = _container(repository, platform, store);
      await first.read(reminderControllerProvider.future);
      expect(
        first.read(reminderControllerProvider).requireValue.permission,
        ReminderPermission.denied,
      );
      await first
          .read(reminderControllerProvider.notifier)
          .save(
            hour: 18,
            minute: 0,
            days: {1, 2, 3, 4, 5, 6, 7},
            content: _content,
          );
      expect(platform.requestCalls, 0);
      first.dispose();

      platform.allowed = true;
      final restarted = _container(repository, platform, store);
      addTearDown(restarted.dispose);
      await restarted.read(reminderControllerProvider.future);
      expect(
        restarted.read(reminderControllerProvider).requireValue.permission,
        ReminderPermission.granted,
      );
      expect(store.denied, isFalse);
    },
  );

  test(
    'creates, updates, pauses, disables and reconciles local schedule',
    () async {
      final platform = _Platform(requestResult: true);
      final repository = _Repository();
      final container = _container(repository, platform, _Store());
      addTearDown(container.dispose);
      await container.read(reminderControllerProvider.future);
      final controller = container.read(reminderControllerProvider.notifier);

      await controller.save(
        hour: 18,
        minute: 0,
        days: {1, 2, 3, 4, 5, 6, 7},
        content: _content,
      );
      await controller.save(
        hour: 8,
        minute: 30,
        days: {1, 3, 5},
        content: _content,
      );
      expect(repository.value?.hour, 8);
      expect(repository.value?.daysOfWeek, {1, 3, 5});
      await controller.pause();
      expect(repository.value?.enabled, isFalse);
      await controller.disable();
      expect(repository.value, isNull);
    },
  );

  test('cold-start lifecycle reconciliation recreates service and uses current IANA timezone without permission request', () async {
    final repository = _Repository()
      ..value = ReminderSchedule.dailyAtSix(
        id: 'reminder-user',
        userId: 'user',
        timezone: 'Asia/Riyadh',
      );
    final platform = _Platform(requestResult: true)..allowed = true;
    await ReminderLifecycleService(
      repository,
      platform,
    ).reconcile(userId: 'user', content: _content);
    // A reconstructed service simulates cold-start/resume code that does not
    // depend on the settings AsyncNotifier ever having built.
    await ReminderLifecycleService(
      repository,
      platform,
    ).reconcile(userId: 'user', content: _content);
    expect(repository.value?.timezone, 'America/New_York');
    expect(platform.requestCalls, 0);
    expect(platform.scheduleCalls, 2);
    expect(platform.scheduled.last.hour, 18);
    expect(platform.scheduled.last.minute, 0);
  });
}

const _content = ReminderNotificationContent(
  title: 'A gentle moment to move',
  body: 'A short, comfortable movement break is here when you are ready.',
);

ProviderContainer _container(
  _Repository repo,
  _Platform platform,
  _Store store,
) => ProviderContainer(
  overrides: [
    authControllerProvider.overrideWith(_Auth.new),
    reminderRepositoryProvider.overrideWithValue(repo),
    reminderPlatformProvider.overrideWithValue(platform),
    reminderPermissionStoreProvider.overrideWithValue(store),
  ],
);

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async =>
      const AuthState(activeUserId: 'user', status: AuthStatus.anonymous);
}

class _Repository implements ReminderRepository {
  ReminderSchedule? value;
  @override
  Future<ReminderSchedule?> read(String _) async => value;
  @override
  Future<void> save(ReminderSchedule schedule) async => value = schedule;
  @override
  Future<void> remove(String _) async => value = null;
}

class _Store implements ReminderPermissionStore {
  var denied = false;
  @override
  Future<bool> wasDenied(String _) async => denied;
  @override
  Future<void> recordDenied(String _) async => denied = true;
  @override
  Future<void> clearDenied(String _) async => denied = false;
}

class _Platform implements ReminderPlatform {
  _Platform({required this.requestResult});
  final bool requestResult;
  var allowed = false;
  var requestCalls = 0;
  var scheduleCalls = 0;
  final List<ReminderSchedule> scheduled = [];
  @override
  Future<ReminderPermission> permissionStatus() async =>
      allowed ? ReminderPermission.granted : ReminderPermission.notDetermined;
  @override
  Future<bool> requestPermission() async {
    requestCalls++;
    return requestResult;
  }

  @override
  Future<String> currentIanaTimezone() async => 'America/New_York';
  @override
  Future<void> schedule(
    ReminderSchedule schedule,
    ReminderNotificationContent content,
  ) async {
    scheduleCalls++;
    scheduled.add(schedule);
    expect(content.title.contains('gentle'), isTrue);
    expect(content.body.contains('comfortable'), isTrue);
  }

  @override
  Future<void> cancel(String _) async {}
  @override
  Future<void> openSettings() async {}
}
