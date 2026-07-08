import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/splash/presentation/widgets/splash_visuals.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _smoke;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1, curve: Curves.easeOut));
    _smoke = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        await context.read<AppRouterCubit>().resolveAfterSplash();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashFestiveBackdrop(),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _smoke.value;
              return IgnorePointer(
                child: Opacity(
                  opacity: 0.45 * t,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - t)),
                    child: const SplashDhunuchiSmokeOverlay(),
                  ),
                ),
              );
            },
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Hero(
                  tag: 'app_logo',
                  child: Material(
                    elevation: 10,
                    shadowColor: AppColors.goldGlow.withValues(alpha: 0.25),
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.brandSecondary, AppColors.brandPrimary, AppColors.warning],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.goldGlow.withValues(alpha: 0.55), width: 1),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const SplashAlpanaHint(),
                          CustomPaint(
                            painter: SplashMukhomondolPainter(
                              eyeColor: AppColors.cream,
                              stroke: scheme.onPrimary.withValues(alpha: 0.9),
                              glow: AppColors.goldGlow,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                'Durga Utsav',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: scheme.onPrimary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
