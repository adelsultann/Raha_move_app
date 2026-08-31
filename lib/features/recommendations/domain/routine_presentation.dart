import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise_library/domain/content_models.dart';

part 'routine_presentation.freezed.dart';

/// One movement in a routine preview, already resolved to a localized name.
@freezed
abstract class MovementPreviewEntry with _$MovementPreviewEntry {
  const factory MovementPreviewEntry({
    required String name,
    required int durationSeconds,
  }) = _MovementPreviewEntry;
}

/// The localized, read-only display view of one routine for the recommendation
/// screen. It is a presentation projection — not the canonical `Routine` model —
/// and is resolved by the data layer from the local Drift content cache.
@freezed
abstract class RoutinePresentation with _$RoutinePresentation {
  const factory RoutinePresentation({
    required String routineId,

    /// Localized routine name (requested locale, falling back to `en`).
    required String name,

    /// Localized intended-benefit summary (requested locale, fallback `en`).
    required String summary,

    /// Ordered, localized movement names and durations.
    required List<MovementPreviewEntry> movements,

    required DifficultyLevel difficulty,
    required int estimatedDurationSeconds,

    /// Stable position taxonomy keys (localized by the presentation layer).
    required Set<String> positions,

    /// Stable equipment taxonomy keys (empty means no equipment).
    required Set<String> equipment,
  }) = _RoutinePresentation;

  const RoutinePresentation._();

  int get movementCount => movements.length;
}
