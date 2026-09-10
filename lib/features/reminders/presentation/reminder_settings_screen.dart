import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../application/reminder_controller.dart';
import '../domain/reminder_schedule.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});
  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen>
    with WidgetsBindingObserver {
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  Set<int> _days = {1, 2, 3, 4, 5, 6, 7};

  ReminderNotificationContent _content() {
    final s = AppLocalizations.of(context);
    return ReminderNotificationContent(
      title: s.reminderNotificationTitle,
      body: s.reminderNotificationBody,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reminderControllerProvider.notifier).reconcile(_content());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      ref.read(reminderControllerProvider.notifier).reconcile(_content());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final state = ref.watch(reminderControllerProvider);
    ref.listen(reminderControllerProvider, (_, next) {
      final schedule = next.value?.schedule;
      if (schedule != null) {
        _time = TimeOfDay(hour: schedule.hour, minute: schedule.minute);
        _days = schedule.daysOfWeek;
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(s.reminderSettingsTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(reminderControllerProvider),
            child: Text(s.retry),
          ),
        ),
        data: (value) {
          final isActive = value.schedule?.enabled == true;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                s.reminderSettingsIntro,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                key: const Key('reminder_time'),
                title: Text(s.reminderSettingsTime),
                subtitle: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(_time),
                ),
                trailing: const Icon(Icons.schedule_outlined),
                onTap: () async {
                  final choice = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (choice != null) setState(() => _time = choice);
                },
              ),
              Semantics(
                label: s.reminderSettingsDays,
                child: Column(
                  children: [
                    ListTile(
                      key: const Key('reminder_every_day'),
                      title: Text(s.reminderSettingsEveryDay),
                      trailing: _days.length == 7
                          ? const Icon(Icons.check)
                          : null,
                      selected: _days.length == 7,
                      onTap: () =>
                          setState(() => _days = {1, 2, 3, 4, 5, 6, 7}),
                    ),
                    ListTile(
                      key: const Key('reminder_weekdays'),
                      title: Text(s.reminderSettingsWeekdays),
                      trailing: _days.length == 5
                          ? const Icon(Icons.check)
                          : null,
                      selected: _days.length == 5,
                      onTap: () => setState(() => _days = {1, 2, 3, 4, 5}),
                    ),
                  ],
                ),
              ),
              if (value.permission == ReminderPermission.denied) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(s.reminderSettingsPermissionDenied),
                ),
                TextButton.icon(
                  key: const Key('reminder_open_settings'),
                  onPressed: () => ref
                      .read(reminderControllerProvider.notifier)
                      .openSettings(),
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(s.reminderSettingsOpenSettings),
                ),
              ],
              if (value.schedulingFailed) ...[
                Text(s.reminderSettingsSaveError),
                TextButton(
                  key: const Key('reminder_retry_schedule'),
                  onPressed: () => ref
                      .read(reminderControllerProvider.notifier)
                      .reconcile(_content()),
                  child: Text(s.reminderSettingsRetry),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('reminder_save'),
                onPressed: () => ref
                    .read(reminderControllerProvider.notifier)
                    .save(
                      hour: _time.hour,
                      minute: _time.minute,
                      days: _days,
                      content: _content(),
                    ),
                child: Text(
                  isActive ? s.reminderSettingsSave : s.reminderSettingsResume,
                ),
              ),
              if (isActive)
                OutlinedButton(
                  key: const Key('reminder_pause'),
                  onPressed: () =>
                      ref.read(reminderControllerProvider.notifier).pause(),
                  child: Text(s.reminderSettingsPause),
                ),
              if (value.schedule != null)
                TextButton(
                  key: const Key('reminder_disable'),
                  onPressed: () =>
                      ref.read(reminderControllerProvider.notifier).disable(),
                  child: Text(s.reminderSettingsDisable),
                ),
            ],
          );
        },
      ),
    );
  }
}
