import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/check_in_controller.dart';
import '../application/check_in_form_state.dart';
import '../domain/body_area.dart';
import '../domain/body_state.dart';
import '../domain/check_in_goal.dart';
import '../domain/check_in_position.dart';

/// The five-step daily check-in: body state, desired outcome, body areas,
/// available time, and usable position — one calm question per screen.
///
/// Answers are retained in the keepAlive [CheckInController] so going backward
/// or returning after an interruption preserves them. The flow cannot advance
/// without a valid answer, and the final step persists one complete check-in.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({
    super.key,
    required this.onExit,
    required this.onComplete,
  });

  /// Invoked when the user leaves the check-in from the first step.
  final VoidCallback onExit;

  /// Invoked after a complete check-in has been saved successfully.
  final VoidCallback onComplete;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  static const int _totalSteps = 5;

  int _step = 0;
  bool _saving = false;

  bool get _isLastStep => _step == _totalSteps - 1;

  bool _isStepValid(CheckInFormState form) {
    return switch (_step) {
      0 => form.bodyState != null,
      1 => form.goal != null,
      2 => form.bodyAreas.isNotEmpty,
      3 => form.availableMinutes != null,
      4 => form.position != null,
      _ => false,
    };
  }

  void _goBack() {
    if (_step == 0) {
      widget.onExit();
      return;
    }
    setState(() => _step -= 1);
  }

  void _advance() {
    final form = ref.read(checkInControllerProvider);
    if (!_isStepValid(form)) return;
    if (_isLastStep) {
      _complete();
      return;
    }
    setState(() => _step += 1);
  }

  Future<void> _complete() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(checkInControllerProvider.notifier)
          .complete();
      if (!mounted) return;
      if (saved) {
        widget.onComplete();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).checkInSaveError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final form = ref.watch(checkInControllerProvider);
    final isValid = _isStepValid(form);

    return SafeArea(
      child: Column(
        children: [
          _Header(step: _step, totalSteps: _totalSteps, onBack: _goBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _StepContent(step: _step, form: form),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('check_in_continue'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isValid && !_saving ? _advance : null,
                    child: Text(strings.checkInContinue),
                  ),
                ),
                if (!isValid) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      strings.checkInRequiredHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.totalSteps,
    required this.onBack,
  });

  final int step;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            key: const Key('check_in_back'),
            tooltip: strings.checkInBack,
            onPressed: onBack,
            icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
          ),
          const Spacer(),
          Semantics(
            container: true,
            child: Text(
              strings.checkInStepIndicator(step + 1, totalSteps),
              key: const Key('check_in_step_indicator'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContent extends ConsumerWidget {
  const _StepContent({required this.step, required this.form});

  final int step;
  final CheckInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (step) {
      0 => _BodyStateStep(form: form),
      1 => _GoalStep(form: form),
      2 => _BodyAreasStep(form: form),
      3 => _TimeStep(form: form),
      4 => _PositionStep(form: form),
      _ => const SizedBox.shrink(),
    };
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, this.hint});

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.headlineMedium),
        ),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(hint!, style: theme.textTheme.bodyLarge),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _BodyStateStep extends ConsumerWidget {
  const _BodyStateStep({required this.form});

  final CheckInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(checkInControllerProvider.notifier);
    final choices = <(BodyState, String, String)>[
      (
        BodyState.comfortable,
        strings.checkInBodyStateComfortable,
        'comfortable',
      ),
      (BodyState.stiff, strings.checkInBodyStateStiff, 'stiff'),
      (BodyState.tired, strings.checkInBodyStateTired, 'tired'),
      (BodyState.tense, strings.checkInBodyStateTense, 'tense'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(title: strings.checkInBodyStateTitle),
        for (final (value, label, key) in choices) ...[
          _ChoiceCard(
            key: Key('check_in_body_state_$key'),
            label: label,
            selected: form.bodyState == value,
            onTap: () => controller.selectBodyState(value),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _GoalStep extends ConsumerWidget {
  const _GoalStep({required this.form});

  final CheckInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(checkInControllerProvider.notifier);
    final choices = <(CheckInGoal, String, String)>[
      (
        CheckInGoal.easeStiffness,
        strings.checkInGoalEaseStiffness,
        'ease_stiffness',
      ),
      (
        CheckInGoal.moveMoreFreely,
        strings.checkInGoalMoveMoreFreely,
        'move_more_freely',
      ),
      (
        CheckInGoal.feelEnergized,
        strings.checkInGoalFeelEnergized,
        'feel_energized',
      ),
      (CheckInGoal.relax, strings.checkInGoalRelax, 'relax'),
      (CheckInGoal.deskBreak, strings.checkInGoalDeskBreak, 'desk_break'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(title: strings.checkInGoalTitle),
        for (final (value, label, key) in choices) ...[
          _ChoiceCard(
            key: Key('check_in_goal_$key'),
            label: label,
            selected: form.goal == value,
            onTap: () => controller.selectGoal(value),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BodyAreasStep extends ConsumerWidget {
  const _BodyAreasStep({required this.form});

  final CheckInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(checkInControllerProvider.notifier);
    final choices = <(BodyArea, String, String)>[
      (BodyArea.neck, strings.checkInAreaNeck, 'neck'),
      (BodyArea.shoulders, strings.checkInAreaShoulders, 'shoulders'),
      (BodyArea.upperBack, strings.checkInAreaUpperBack, 'upper_back'),
      (BodyArea.lowerBack, strings.checkInAreaLowerBack, 'lower_back'),
      (BodyArea.hips, strings.checkInAreaHips, 'hips'),
      (BodyArea.knees, strings.checkInAreaKnees, 'knees'),
      (BodyArea.fullBody, strings.checkInAreaFullBody, 'full_body'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          title: strings.checkInBodyAreasTitle,
          hint: strings.checkInBodyAreasHint,
        ),
        for (final (value, label, key) in choices) ...[
          _ChoiceCard(
            key: Key('check_in_area_$key'),
            label: label,
            selected: form.bodyAreas.contains(value),
            onTap: () => controller.toggleBodyArea(value),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TimeStep extends ConsumerWidget {
  const _TimeStep({required this.form});

  final CheckInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(checkInControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(title: strings.checkInTimeTitle),
        for (final minutes in const [3, 5, 10, 15]) ...[
          _ChoiceCard(
            key: Key('check_in_time_$minutes'),
            label: strings.checkInTimeMinutes(minutes),
            selected: form.availableMinutes == minutes,
            onTap: () => controller.selectTime(minutes),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PositionStep extends ConsumerWidget {
  const _PositionStep({required this.form});

  final CheckInFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(checkInControllerProvider.notifier);
    final choices = <(CheckInPosition, String, String)>[
      (CheckInPosition.seated, strings.checkInPositionSeated, 'seated'),
      (CheckInPosition.standing, strings.checkInPositionStanding, 'standing'),
      (CheckInPosition.floor, strings.checkInPositionFloor, 'floor'),
      (CheckInPosition.any, strings.checkInPositionAny, 'any'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(title: strings.checkInPositionTitle),
        for (final (value, label, key) in choices) ...[
          _ChoiceCard(
            key: Key('check_in_position_$key'),
            label: label,
            selected: form.position == value,
            onTap: () => controller.selectPosition(value),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// A calm, single-selection (or toggling) card shared across all steps.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
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
