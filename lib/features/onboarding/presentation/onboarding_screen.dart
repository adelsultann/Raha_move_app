import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

/// The introductory onboarding: at most three concise pages explaining
/// personalized choice, short routines, and comfortable habit building.
///
/// The final page completes onboarding as a guest; registration is never
/// required.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});

  /// Invoked when the user taps the primary action on the final page.
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isLast = _page == _pageCount - 1;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Semantics(
              label: strings.onboardingPageIndicator(_page + 1, _pageCount),
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _pages(strings)[index],
              ),
            ),
          ),
          _PageDots(count: _pageCount, current: _page),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: Key(isLast ? 'onboarding_get_started' : 'onboarding_next'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: isLast ? widget.onFinish : _next,
                child: Text(
                  isLast
                      ? strings.onboardingGetStarted
                      : strings.onboardingNext,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  List<Widget> _pages(AppLocalizations strings) => [
    _OnboardingPage(
      icon: Icons.self_improvement_outlined,
      title: strings.onboardingPageOneTitle,
      body: strings.onboardingPageOneBody,
    ),
    _OnboardingPage(
      icon: Icons.schedule_outlined,
      title: strings.onboardingPageTwoTitle,
      body: strings.onboardingPageTwoBody,
    ),
    _OnboardingPage(
      icon: Icons.favorite_border_outlined,
      title: strings.onboardingPageThreeTitle,
      body: strings.onboardingPageThreeBody,
    ),
  ];
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
