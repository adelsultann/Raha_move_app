import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/preferences_controller.dart';
import '../application/preferences_form_state.dart';
import '../domain/experience_level.dart';
import '../domain/movement_position.dart';

/// The basic-preferences capture step shown between onboarding and the app.
///
/// Captures only movement experience, preferred positions, weekly goal, and
/// reminder interest. Experience level is required; everything else has a
/// gentle default. Answers are retained in the keepAlive controller so going
/// backward or returning after an interruption preserves them.
class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  /// Invoked when the user returns to the onboarding pages.
  final VoidCallback onBack;

  /// Invoked after the preferences have been saved successfully.
  final VoidCallback onComplete;

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(preferencesControllerProvider.notifier)
          .save();
      if (!mounted) return;
      if (saved) {
        widget.onComplete();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).preferencesSaveError),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final form = ref.watch(preferencesControllerProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              key: const Key('preferences_back'),
              tooltip: strings.preferencesBack,
              onPressed: widget.onBack,
              icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
            ),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                strings.preferencesTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(strings.preferencesSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 28),
            _ExperienceSection(form: form),
            const SizedBox(height: 28),
            _PositionsSection(form: form),
            const SizedBox(height: 28),
            _WeeklyGoalSection(form: form),
            const SizedBox(height: 8),
            _ReminderSection(form: form),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('preferences_continue'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: form.isValid && !_saving ? _save : null,
                child: Text(strings.preferencesContinue),
              ),
            ),
            if (!form.isValid) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  strings.preferencesRequiredHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExperienceSection extends ConsumerWidget {
  const _ExperienceSection({required this.form});

  final PreferencesFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(preferencesControllerProvider.notifier);

    return _Section(
      label: strings.preferencesExperienceLabel,
      required: true,
      child: Column(
        children: [
          _SelectCard(
            key: const Key('preferences_experience_beginner'),
            label: strings.preferencesExperienceBeginner,
            selected: form.experienceLevel == ExperienceLevel.beginner,
            onTap: () => controller.selectExperience(ExperienceLevel.beginner),
          ),
          const SizedBox(height: 12),
          _SelectCard(
            key: const Key('preferences_experience_intermediate'),
            label: strings.preferencesExperienceIntermediate,
            selected: form.experienceLevel == ExperienceLevel.intermediate,
            onTap: () =>
                controller.selectExperience(ExperienceLevel.intermediate),
          ),
          const SizedBox(height: 12),
          _SelectCard(
            key: const Key('preferences_experience_advanced'),
            label: strings.preferencesExperienceAdvanced,
            selected: form.experienceLevel == ExperienceLevel.advanced,
            onTap: () => controller.selectExperience(ExperienceLevel.advanced),
          ),
        ],
      ),
    );
  }
}

class _PositionsSection extends ConsumerWidget {
  const _PositionsSection({required this.form});

  final PreferencesFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(preferencesControllerProvider.notifier);

    return _Section(
      label: strings.preferencesPositionsLabel,
      hint: strings.preferencesPositionsHint,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _PositionChip(
            key: const Key('preferences_position_seated'),
            label: strings.preferencesPositionSeated,
            selected: form.preferredPositions.contains(MovementPosition.seated),
            onSelected: (_) =>
                controller.togglePosition(MovementPosition.seated),
          ),
          _PositionChip(
            key: const Key('preferences_position_standing'),
            label: strings.preferencesPositionStanding,
            selected: form.preferredPositions.contains(
              MovementPosition.standing,
            ),
            onSelected: (_) =>
                controller.togglePosition(MovementPosition.standing),
          ),
          _PositionChip(
            key: const Key('preferences_position_floor'),
            label: strings.preferencesPositionFloor,
            selected: form.preferredPositions.contains(MovementPosition.floor),
            onSelected: (_) =>
                controller.togglePosition(MovementPosition.floor),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalSection extends ConsumerWidget {
  const _WeeklyGoalSection({required this.form});

  final PreferencesFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(preferencesControllerProvider.notifier);

    return _Section(
      label: strings.preferencesWeeklyGoalLabel,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const Key('preferences_weekly_goal_decrement'),
            tooltip: strings.preferencesFewerDays,
            onPressed: form.weeklyGoalDays > 1
                ? () => controller.setWeeklyGoal(form.weeklyGoalDays - 1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 96,
            child: Column(
              children: [
                Semantics(
                  value: '${form.weeklyGoalDays}',
                  child: Text(
                    '${form.weeklyGoalDays}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                Text(
                  strings.preferencesDaysPerWeek,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('preferences_weekly_goal_increment'),
            tooltip: strings.preferencesMoreDays,
            onPressed: form.weeklyGoalDays < 7
                ? () => controller.setWeeklyGoal(form.weeklyGoalDays + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class _ReminderSection extends ConsumerWidget {
  const _ReminderSection({required this.form});

  final PreferencesFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(preferencesControllerProvider.notifier);

    return SwitchListTile(
      key: const Key('preferences_reminder_toggle'),
      contentPadding: EdgeInsets.zero,
      title: Text(strings.preferencesReminderLabel),
      subtitle: Text(strings.preferencesReminderSubtitle),
      value: form.reminderInterest,
      onChanged: controller.setReminderInterest,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.child,
    this.hint,
    this.required = false,
  });

  final String label;
  final String? hint;
  final bool required;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            if (required)
              Text(
                strings.preferencesRequired,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: scheme.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionChip extends StatelessWidget {
  const _PositionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
