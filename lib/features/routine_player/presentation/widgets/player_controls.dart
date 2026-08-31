import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

/// The Previous / Pause-Resume / Skip-Finish controls row for the focused
/// routine player (RAHA-051). Every control has a stable key, a localized
/// tooltip (semantics label), a minimum 48dp touch target, and directional
/// arrows that mirror RTL like the recommendation screen.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isLastStep,
    required this.onPrevious,
    required this.onTogglePause,
    required this.onSkip,
    required this.onFinish,
  });

  final bool isPlaying;
  final bool isLastStep;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePause;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('player_previous'),
          tooltip: strings.playerPrevious,
          iconSize: 28,
          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          onPressed: onPrevious,
          icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
        ),
        const SizedBox(width: 20),
        IconButton.filled(
          key: const Key('player_pause'),
          tooltip: isPlaying ? strings.playerPause : strings.playerResume,
          iconSize: 34,
          style: IconButton.styleFrom(
            minimumSize: const Size(72, 72),
            shape: const CircleBorder(),
          ),
          onPressed: onTogglePause,
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(width: 20),
        if (isLastStep)
          FilledButton.icon(
            key: const Key('player_finish'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 56),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onFinish,
            icon: const Icon(Icons.check),
            label: Text(strings.playerFinish),
          )
        else
          IconButton(
            key: const Key('player_skip'),
            tooltip: strings.playerSkip,
            iconSize: 28,
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            onPressed: onSkip,
            icon: Icon(isRtl ? Icons.arrow_back : Icons.arrow_forward),
          ),
      ],
    );
  }
}
