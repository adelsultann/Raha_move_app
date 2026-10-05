import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

class ExercisePreviewVideoFallback extends StatelessWidget {
  const ExercisePreviewVideoFallback({
    super.key,
    required this.poster,
    this.onRetry,
  });

  final String poster;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          poster,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) =>
              const Center(child: Icon(Icons.videocam_off_outlined, size: 48)),
        ),
        PositionedDirectional(
          start: 12,
          end: 12,
          bottom: 12,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.exercisePreviewVideoUnavailable,
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null)
                    TextButton(
                      key: const Key('exercise_preview_video_retry'),
                      onPressed: onRetry,
                      child: Text(strings.retry),
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
