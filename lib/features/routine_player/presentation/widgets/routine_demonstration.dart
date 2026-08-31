import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routine_demonstration.g.dart';

/// The renderer boundary for the current movement demonstration (RAHA-051).
///
/// The player renders whatever this returns, so a future `video_player`-backed
/// renderer is a drop-in replacement behind the same interface. RAHA-051 ships
/// a calm, looping placeholder because playable media is not yet deliverable.
abstract interface class RoutineDemonstration {
  Widget build(BuildContext context, {required bool playing});
}

/// Injectable demonstration renderer. Tests and a future video renderer
/// override this provider.
@riverpod
RoutineDemonstration routineDemonstration(Ref ref) =>
    const LoopingRoutineDemonstration();

/// A looping, calm placeholder that gently pulses while playing and stops while
/// paused. It never plays media and is deliberately provider-independent.
final class LoopingRoutineDemonstration implements RoutineDemonstration {
  const LoopingRoutineDemonstration();

  @override
  Widget build(BuildContext context, {required bool playing}) {
    return _LoopingDemonstration(playing: playing);
  }
}

class _LoopingDemonstration extends StatefulWidget {
  const _LoopingDemonstration({required this.playing});

  final bool playing;

  @override
  State<_LoopingDemonstration> createState() => _LoopingDemonstrationState();
}

class _LoopingDemonstrationState extends State<_LoopingDemonstration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_LoopingDemonstration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.playing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Semantics(
        label: AppLocalizations.of(context).playerDemonstration,
        image: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final scale = 0.92 + 0.08 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
            return Transform.rotate(
              angle: t * 2 * math.pi * 0.03,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.self_improvement,
              size: 88,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
