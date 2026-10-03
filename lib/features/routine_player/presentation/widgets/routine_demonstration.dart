import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

part 'routine_demonstration.g.dart';

/// The renderer boundary for the current movement demonstration (RAHA-051).
///
/// The player renders whatever this returns, so a future `video_player`-backed
/// renderer is a drop-in replacement behind the same interface. RAHA-051 ships
/// a calm, looping placeholder because playable media is not yet deliverable.
abstract interface class RoutineDemonstration {
  Widget build(
    BuildContext context, {
    required String? deliveryReference,
    required bool playing,
  });
}

/// Injectable demonstration renderer. Tests and a future video renderer
/// override this provider.
@riverpod
RoutineDemonstration routineDemonstration(Ref ref) =>
    const MediaRoutineDemonstration();

/// Renders approved bundled GIF/MP4 demonstrations and keeps the existing
/// provider-neutral placeholder for opaque remote references. Remote media
/// will use the same boundary once its verified cache path is exposed to the
/// player.
final class MediaRoutineDemonstration implements RoutineDemonstration {
  const MediaRoutineDemonstration();

  static const _assetPrefix = 'asset:';

  @override
  Widget build(
    BuildContext context, {
    required String? deliveryReference,
    required bool playing,
  }) {
    final reference = deliveryReference ?? '';
    if (!reference.startsWith(_assetPrefix)) {
      return const LoopingRoutineDemonstration().build(
        context,
        deliveryReference: deliveryReference,
        playing: playing,
      );
    }
    final path = reference.substring(_assetPrefix.length);
    if (path.endsWith('.gif')) {
      return Semantics(
        label: AppLocalizations.of(context).playerDemonstration,
        image: true,
        child: Image.asset(path, fit: BoxFit.contain, gaplessPlayback: true),
      );
    }
    if (path.endsWith('.mp4')) {
      return _AssetVideoDemonstration(
        key: ValueKey(path),
        assetPath: path,
        playing: playing,
      );
    }
    return const LoopingRoutineDemonstration().build(
      context,
      deliveryReference: deliveryReference,
      playing: playing,
    );
  }
}

/// A looping, calm placeholder that gently pulses while playing and stops while
/// paused. It never plays media and is deliberately provider-independent.
final class LoopingRoutineDemonstration implements RoutineDemonstration {
  const LoopingRoutineDemonstration();

  @override
  Widget build(
    BuildContext context, {
    required String? deliveryReference,
    required bool playing,
  }) {
    return _LoopingDemonstration(playing: playing);
  }
}

class _AssetVideoDemonstration extends StatefulWidget {
  const _AssetVideoDemonstration({
    super.key,
    required this.assetPath,
    required this.playing,
  });

  final String assetPath;
  final bool playing;

  @override
  State<_AssetVideoDemonstration> createState() =>
      _AssetVideoDemonstrationState();
}

class _AssetVideoDemonstrationState extends State<_AssetVideoDemonstration> {
  late final VideoPlayerController _controller;
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      if (!mounted) return;
      _ready = true;
      await _syncPlayback();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(_AssetVideoDemonstration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _syncPlayback();
  }

  Future<void> _syncPlayback() async {
    if (!_ready) return;
    if (widget.playing) {
      await _controller.play();
    } else {
      await _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const LoopingRoutineDemonstration().build(
        context,
        deliveryReference: null,
        playing: false,
      );
    }
    if (!_ready) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Semantics(
        label: AppLocalizations.of(context).playerDemonstration,
        image: true,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
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
  var _reduceMotion = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion != reduceMotion) {
      _reduceMotion = reduceMotion;
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.playing && !_reduceMotion) {
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
            if (_reduceMotion) return child!;
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
