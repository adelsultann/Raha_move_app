import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';

import '../application/recommendation_controller.dart';
import '../application/recommendation_providers.dart';
import '../application/recommendation_state.dart';
import '../domain/recommendation_engine.dart';
import '../domain/recommendation_explanation.dart';
import '../domain/routine_presentation.dart';
import 'widgets/movement_preview_sheet.dart';

/// Presents one explainable recommendation after a completed check-in.
///
/// It shows the localized routine name, duration, movement count, difficulty,
/// position, and equipment, a "why this routine?" explanation generated from the
/// stored reason keys and the user's actual answers, a concise movement preview,
/// and a single primary start action plus a "Choose another" rejection action.
class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({
    super.key,
    required this.checkInId,
    this.onStart,
    this.onChooseAnother,
  });

  final String checkInId;

  /// Invoked by the primary "Start routine" action. Wired to the routine player
  /// in RAHA-050.
  final VoidCallback? onStart;

  /// Invoked by "Choose another". Wired to the alternative flow in RAHA-043.
  final VoidCallback? onChooseAnother;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final stateAsync = ref.watch(recommendationControllerProvider(checkInId));

    return Scaffold(
      body: SafeArea(
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _RetryState(
            title: strings.recommendationUnavailable,
            onRetry: () =>
                ref.invalidate(recommendationControllerProvider(checkInId)),
          ),
          data: (state) {
            final selected = state.selected;
            if (selected == null) {
              return _RetryState(
                title: strings.recommendationEmptyTitle,
                message: strings.recommendationEmptyBody,
                onRetry: () =>
                    ref.invalidate(recommendationControllerProvider(checkInId)),
              );
            }
            final presentationAsync = ref.watch(
              routinePresentationProvider(selected.routineId),
            );
            return presentationAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _RetryState(
                title: strings.recommendationUnavailable,
                onRetry: () => ref.invalidate(
                  routinePresentationProvider(selected.routineId),
                ),
              ),
              data: (presentation) => _RecommendationContent(
                state: state,
                selected: selected,
                presentation: presentation,
                onStart: onStart,
                onChooseAnother: onChooseAnother,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecommendationContent extends ConsumerWidget {
  const _RecommendationContent({
    required this.state,
    required this.selected,
    required this.presentation,
    required this.onStart,
    required this.onChooseAnother,
  });

  final RecommendationState state;
  final ScoredRoutine selected;
  final RoutinePresentation presentation;
  final VoidCallback? onStart;
  final VoidCallback? onChooseAnother;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        _Header(onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    presentation.name,
                    key: const Key('recommendation_routine_name'),
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 12),
                _ChipRow(presentation: presentation),
                const SizedBox(height: 24),
                _WhySection(
                  checkIn: state.checkIn,
                  reasonCodes: selected.reasonCodes,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  key: const Key('recommendation_preview'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () =>
                      showMovementPreviewSheet(context, presentation.movements),
                  icon: const Icon(Icons.list_alt),
                  label: Text(strings.recommendationPreviewMovements),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('recommendation_start'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onStart,
                  child: Text(strings.recommendationStart),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('recommendation_choose_another'),
                onPressed: onChooseAnother,
                child: Text(strings.recommendationChooseAnother),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            key: const Key('recommendation_back'),
            tooltip: strings.recommendationBack,
            onPressed: onBack,
            icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              strings.recommendationTitle,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.presentation});

  final RoutinePresentation presentation;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    final chips = <String>[
      _durationLabel(strings, presentation.estimatedDurationSeconds),
      strings.recommendationMovementsCount(presentation.movementCount),
      _difficultyLabel(strings, presentation.difficulty),
      _positionLabel(strings, presentation.positions),
      _equipmentLabel(strings, presentation.equipment),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in chips)
          Chip(label: Text(label), visualDensity: VisualDensity.compact),
      ],
    );
  }
}

class _WhySection extends StatelessWidget {
  const _WhySection({required this.checkIn, required this.reasonCodes});

  final CheckInAnswers checkIn;
  final List<String> reasonCodes;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final reasons = buildExplanationReasons(
      reasonCodes: reasonCodes,
      positionKey: checkIn.positionKey,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.recommendationWhyTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final reason in reasons) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _lineFor(strings, reason, checkIn),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _lineFor(
    AppLocalizations strings,
    ExplanationReason reason,
    CheckInAnswers checkIn,
  ) {
    return switch (reason) {
      ExplanationReason.bodyAreaMatch => strings.recommendationReasonBodyAreas(
        _joinLabels(
          strings,
          checkIn.bodyAreaKeys.map((key) => _areaLabel(strings, key)),
        ),
      ),
      ExplanationReason.goalMatch => strings.recommendationReasonGoal(
        _goalLabel(strings, checkIn.goalKey),
      ),
      ExplanationReason.timeFit => strings.recommendationReasonTime(
        checkIn.availableMinutes,
      ),
      ExplanationReason.position => strings.recommendationReasonPosition(
        checkIn.positionKey == null
            ? strings.checkInPositionAny
            : _positionKeyLabel(strings, checkIn.positionKey!),
      ),
      ExplanationReason.difficultyMatch =>
        strings.recommendationReasonDifficulty,
      ExplanationReason.recentCompletion => strings.recommendationReasonRecent,
      ExplanationReason.previousDiscomfort =>
        strings.recommendationReasonDiscomfort,
    };
  }

  String _joinLabels(AppLocalizations strings, Iterable<String> labels) {
    final isArabic = strings.localeName.startsWith('ar');
    return labels.join(isArabic ? '، ' : ', ');
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.title, required this.onRetry, this.message});

  final String title;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                key: const Key('recommendation_back'),
                tooltip: strings.recommendationBack,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('recommendation_retry'),
                    onPressed: onRetry,
                    child: Text(strings.recommendationRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _durationLabel(AppLocalizations strings, int seconds) {
  if (seconds < 60 || seconds % 60 != 0) {
    return strings.recommendationSeconds(seconds);
  }
  return strings.recommendationDurationMinutes(seconds ~/ 60);
}

String _difficultyLabel(AppLocalizations strings, DifficultyLevel difficulty) {
  return switch (difficulty) {
    DifficultyLevel.beginner => strings.recommendationDifficultyBeginner,
    DifficultyLevel.intermediate =>
      strings.recommendationDifficultyIntermediate,
    DifficultyLevel.advanced => strings.recommendationDifficultyAdvanced,
  };
}

String _positionLabel(AppLocalizations strings, Set<String> keys) {
  if (keys.isEmpty) return strings.checkInPositionAny;
  return keys.map((key) => _positionKeyLabel(strings, key)).join(' · ');
}

String _positionKeyLabel(AppLocalizations strings, String key) => switch (key) {
  'seated' => strings.checkInPositionSeated,
  'standing' => strings.checkInPositionStanding,
  'floor' => strings.checkInPositionFloor,
  _ => key,
};

String _equipmentLabel(AppLocalizations strings, Set<String> keys) {
  if (keys.isEmpty || (keys.length == 1 && keys.contains('body_weight'))) {
    return strings.recommendationNoEquipment;
  }
  return keys.join(' · ');
}

String _areaLabel(AppLocalizations strings, String key) => switch (key) {
  'neck' => strings.checkInAreaNeck,
  'shoulders' => strings.checkInAreaShoulders,
  'upper_back' => strings.checkInAreaUpperBack,
  'lower_back' => strings.checkInAreaLowerBack,
  'hips' => strings.checkInAreaHips,
  'knees' => strings.checkInAreaKnees,
  'full_body' => strings.checkInAreaFullBody,
  _ => key,
};

String _goalLabel(AppLocalizations strings, String key) => switch (key) {
  'ease_stiffness' => strings.checkInGoalEaseStiffness,
  'move_more_freely' => strings.checkInGoalMoveMoreFreely,
  'feel_energized' => strings.checkInGoalFeelEnergized,
  'relax' => strings.checkInGoalRelax,
  'desk_break' => strings.checkInGoalDeskBreak,
  _ => key,
};
