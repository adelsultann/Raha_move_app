import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

import 'exercise_preview_video_fallback.dart';

/// Owns preview playback only; viewing an exercise never starts a session.
class ExercisePreviewVideo extends StatefulWidget {
  const ExercisePreviewVideo({
    super.key,
    required this.asset,
    required this.poster,
  });

  final String? asset;
  final String poster;

  @override
  State<ExercisePreviewVideo> createState() => _ExercisePreviewVideoState();
}

class _ExercisePreviewVideoState extends State<ExercisePreviewVideo>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _ready = false;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final asset = widget.asset;
    if (asset == null) return;
    // This widget owns lifecycle pauses. Disable the plugin's automatic
    // foreground resume so returning to the app remains user-controlled.
    final controller = VideoPlayerController.asset(
      asset,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    _controller = controller;
    controller.addListener(_onVideoChanged);
    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) return;
      _ready = true;
      await _syncPlayback();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _onVideoChanged() {
    if (mounted && !_failed && (_controller?.value.hasError ?? false)) {
      setState(() => _failed = true);
    }
  }

  Future<void> _retry() async {
    final old = _controller;
    old?.removeListener(_onVideoChanged);
    setState(() {
      _failed = false;
      _ready = false;
      _playing = true;
    });
    await old?.dispose();
    if (mounted) await _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _playing) {
      setState(() => _playing = false);
      unawaited(_syncPlayback());
    }
  }

  Future<void> _syncPlayback() async {
    if (!_ready) return;
    try {
      if (_playing) {
        await _controller!.play();
      } else {
        await _controller!.pause();
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onVideoChanged);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final unavailable = widget.asset == null || _failed;
    return AspectRatio(
      aspectRatio: 1,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (unavailable)
              ExercisePreviewVideoFallback(
                poster: widget.poster,
                onRetry: _failed ? () => unawaited(_retry()) : null,
              )
            else if (!_ready)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Semantics(
                  label: strings.playerDemonstration,
                  image: true,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            if (!unavailable && _ready)
              PositionedDirectional(
                end: 12,
                bottom: 12,
                child: IconButton.filledTonal(
                  key: const Key('exercise_preview_play_pause'),
                  tooltip: _playing
                      ? strings.playerPause
                      : strings.playerResume,
                  onPressed: () {
                    setState(() => _playing = !_playing);
                    unawaited(_syncPlayback());
                  },
                  icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
