import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/l10n/app_localizations.dart';
import '../../authentication/application/auth_controller.dart';
import '../application/reminder_providers.dart';
import '../domain/reminder_schedule.dart';

/// App-scoped foreground reconciliation; it never requests permission.
class ReminderLifecycleReconciler extends ConsumerStatefulWidget {
  const ReminderLifecycleReconciler({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<ReminderLifecycleReconciler> createState() =>
      _ReminderLifecycleReconcilerState();
}

class _ReminderLifecycleReconcilerState
    extends ConsumerState<ReminderLifecycleReconciler>
    with WidgetsBindingObserver {
  ReminderNotificationContent _content(BuildContext context) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _reconcile());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reconcile();
    }
  }

  Future<void> _reconcile() async {
    final auth = await ref.read(authControllerProvider.future);
    final userId = auth.activeUserId;
    if (userId == null || !mounted) return;
    try {
      await ref
          .read(reminderLifecycleServiceProvider)
          .reconcile(userId: userId, content: _content(context));
    } catch (_) {
      // A later resume retries a transient platform scheduling failure.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
