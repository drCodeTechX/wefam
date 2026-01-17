import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wefam/providers/onboarding_provider.dart';
import 'package:wefam/core/theme/colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      type: OnboardingPageType.welcome,
      title: 'Welcome Home',
      subtitle: 'A place where families grow together in faith, love, and community',
    ),
    OnboardingPageData(
      type: OnboardingPageType.scripture,
      title: '"How good and pleasant it is when God\'s people live together in unity!"',
      subtitle: '— Psalm 133:1',
    ),
    OnboardingPageData(
      type: OnboardingPageType.community,
      title: 'Together, We Grow',
      subtitle: 'Share prayers, celebrate moments, and walk alongside your fellowship family — every step of the way.',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleGetStarted() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient layers
          Positioned(
            top: -100,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating decorative circles
          _buildFloatingCircle(top: 120, left: 30, size: 60, borderColor: AppColors.primary.withOpacity(0.15)),
          _buildFloatingCircle(top: 400, right: 25, size: 40, borderColor: Colors.red.withOpacity(0.2)),
          _buildFloatingCircle(bottom: 180, left: 50, size: 30, borderColor: AppColors.primary.withOpacity(0.2)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                if (_currentPage < _pages.length - 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: () => _goToPage(_pages.length - 1),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 56),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index == _pages.length - 1);
                    },
                  ),
                ),

                // Navigation dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => GestureDetector(
                        onTap: () => _goToPage(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: _currentPage == index ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color borderColor,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(seconds: 3),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (0.5 - value).abs() * 2 - 10),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page, bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Illustration
          _buildPageIcon(page.type),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: page.type == OnboardingPageType.scripture ? 'serif' : null,
              fontSize: page.type == OnboardingPageType.scripture ? 28 : 36,
              fontWeight: FontWeight.w600,
              fontStyle: page.type == OnboardingPageType.scripture ? FontStyle.italic : FontStyle.normal,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: page.type == OnboardingPageType.scripture ? 15 : 16,
              fontWeight: page.type == OnboardingPageType.scripture ? FontWeight.w600 : FontWeight.w400,
              color: page.type == OnboardingPageType.scripture 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
              height: 1.6,
              letterSpacing: page.type == OnboardingPageType.scripture ? 1 : 0,
            ),
          ),

          // Accent line for scripture page
          if (page.type == OnboardingPageType.scripture) ...[
            const SizedBox(height: 30),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],

          // Get Started button on last page
          if (isLastPage) ...[
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _handleGetStarted,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.35),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIcon(OnboardingPageType type) {
    switch (type) {
      case OnboardingPageType.welcome:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.9),
                ),
              ),
              // Hearts around
              Positioned(
                top: 15,
                left: 20,
                child: Icon(Icons.favorite, color: Colors.red.shade600, size: 24),
              ),
              Positioned(
                top: 15,
                right: 20,
                child: Icon(Icons.favorite, color: Colors.red.shade600, size: 24),
              ),
              Positioned(
                bottom: 15,
                child: Icon(Icons.favorite, color: Colors.red.shade600, size: 24),
              ),
            ],
          ),
        );
      case OnboardingPageType.scripture:
        return Text(
          '"',
          style: TextStyle(
            fontSize: 100,
            color: AppColors.primary.withOpacity(0.15),
            height: 0.8,
          ),
        );
      case OnboardingPageType.community:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.person, size: 50, color: AppColors.primary.withOpacity(0.4)),
            Icon(Icons.person, size: 65, color: AppColors.primary),
            Icon(Icons.person, size: 50, color: AppColors.primary.withOpacity(0.4)),
          ],
        );
    }
  }
}

enum OnboardingPageType { welcome, scripture, community }

class OnboardingPageData {
  final OnboardingPageType type;
  final String title;
  final String subtitle;

  OnboardingPageData({
    required this.type,
    required this.title,
    required this.subtitle,
  });
}
