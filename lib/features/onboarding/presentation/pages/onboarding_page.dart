import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = [
      _OnboardSlide(
        icon: Icons.temple_hindu_rounded,
        title: t.onboardingTitle1,
        subtitle: t.onboardingSubtitle1,
      ),
      _OnboardSlide(
        icon: Icons.alt_route_rounded,
        title: t.onboardingTitle2,
        subtitle: t.onboardingSubtitle2,
      ),
      _OnboardSlide(
        icon: Icons.share_location_rounded,
        title: t.onboardingTitle3,
        subtitle: t.onboardingSubtitle3,
      ),
      _OnboardSlide(
        icon: Icons.shopping_bag_rounded,
        title: t.onboardingTitle4,
        subtitle: t.onboardingSubtitle4,
      ),
    ];
    return BlocProvider(
      create: (_) => OnboardingCubit(pageCount: pages.length),
      child: _OnboardingView(pages: pages),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView({required this.pages});

  final List<_OnboardSlide> pages;

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
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.read<AppRouterCubit>().completeOnboarding(),
            child: Text(t.skip),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.pages.length,
                onPageChanged: context.read<OnboardingCubit>().goToPage,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: widget.pages[i],
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
                          widget.pages.length,
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
                          child: Text(cubit.isLast ? t.getStarted : t.next),
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
