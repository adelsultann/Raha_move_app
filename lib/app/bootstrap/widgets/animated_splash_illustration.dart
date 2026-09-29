import 'package:flutter/material.dart';

/// A calm, decorative breathing motion for the startup illustration.
///
/// The animation automatically becomes static when the operating system asks
/// for reduced motion. The artwork is excluded from semantics because the
/// surrounding splash screen announces the useful loading state.
class AnimatedSplashIllustration extends StatefulWidget {
  const AnimatedSplashIllustration({super.key});

  static const assetPath = 'assets/images/splash_breathing_arc.png';

  @override
  State<AnimatedSplashIllustration> createState() =>
      _AnimatedSplashIllustrationState();
}

class _AnimatedSplashIllustrationState extends State<AnimatedSplashIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _breath;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _breath = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion == reduceMotion) return;

    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _breath,
          builder: (context, child) {
            final value = _breath.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: 0.92 + (value * 0.08),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary.withValues(
                            alpha: 0.13 + (value * 0.05),
                          ),
                          colorScheme.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -4 * value),
                  child: Transform.scale(
                    scale: 1 + (0.018 * value),
                    child: child,
                  ),
                ),
              ],
            );
          },
          child: Image.asset(
            AnimatedSplashIllustration.assetPath,
            key: const Key('splash_breathing_arc'),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
