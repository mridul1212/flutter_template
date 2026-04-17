import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _pages = [
    _OnboardSlide(
      icon: Icons.auto_awesome_mosaic_rounded,
      title: 'Organize your day',
      subtitle: 'A calm home for tasks, notes, and reminders — tuned for focus.',
    ),
    _OnboardSlide(
      icon: Icons.shield_moon_rounded,
      title: 'Private by default',
      subtitle: 'Local-first patterns you can extend with your own backend later.',
    ),
    _OnboardSlide(
      icon: Icons.rocket_launch_rounded,
      title: 'Ship faster',
      subtitle: 'Clean architecture + BLoC/Cubit so features stay easy to grow.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(pageCount: _pages.length),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.read<AppRouterCubit>().completeOnboarding(),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingPage._pages.length,
                onPageChanged: context.read<OnboardingCubit>().goToPage,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: OnboardingPage._pages[i],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: BlocBuilder<OnboardingCubit, int>(
                builder: (context, index) {
                  final cubit = context.read<OnboardingCubit>();
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          OnboardingPage._pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: i == index ? 28 : 8,
                            decoration: BoxDecoration(
                              color: i == index ? scheme.primary : scheme.outlineVariant,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (cubit.isLast) {
                              await context.read<AppRouterCubit>().completeOnboarding();
                              return;
                            }
                            await _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: Text(cubit.isLast ? 'Get started' : 'Next'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 72, color: scheme.primary),
        const SizedBox(height: 28),
        Text(title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(subtitle, style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.4)),
      ],
    );
  }
}
