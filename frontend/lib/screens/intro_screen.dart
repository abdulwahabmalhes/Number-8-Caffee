import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/n8_logo.dart';
import 'phone_auth_screen.dart';
class OnboardingItem {
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final String imageAsset;

  const OnboardingItem({
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.imageAsset,
  });
}

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      titleAr: 'اطلب من طاولتك مباشرة',
      titleEn: 'Order Directly from Your Table',
      descAr: 'امسح رمز QR الموجود على طاولتك، تصفح المنيو، وادفع بكل سهولة وسرعة.',
      descEn: 'Scan the QR code on your table, customize your drink, and pay seamlessly.',
      imageAsset: 'assets/images/intro_table.jpg',
    ),
    OnboardingItem(
      titleAr: 'اطلب من سيارتك قبل وصولك',
      titleEn: 'Order from Your Car Before Arrival',
      descAr: 'حدد رقم لوحتك وموديل سيارتك وسنجهز طلبك لتستلمه فور وصولك بدون انتظار.',
      descEn: 'Enter your car plate and model, and we will deliver your order to your car window.',
      imageAsset: 'assets/images/intro_car.jpg',
    ),
    OnboardingItem(
      titleAr: 'تصفح القائمة وخصص مشروبك',
      titleEn: 'Explore the Menu & Customize',
      descAr: 'اختر نوع الحليب، حجم الكوب، والشوت الإضافي بحسب رغبتك بلمسة واحدة.',
      descEn: 'Customize sizes, milk options, and espresso shots exactly to your taste.',
      imageAsset: 'assets/images/intro_brew.jpg',
    ),
    OnboardingItem(
      titleAr: 'اجمع النقاط والمكافآت مع كل طلب',
      titleEn: 'Earn Rewards with Every Order',
      descAr: 'اشترِ 8 أكواب واحصل على الكوب التاسع مجاناً، بالإضافة لمزايا المستوى الذهبي.',
      descEn: 'Buy 8 cups and get your 9th cup on us, plus exclusive Gold Tier perks.',
      imageAsset: 'assets/images/intro_loyalty.jpg',
    ),
  ];

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // PageView Background Images & Gradient Overlay
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // High Definition Local Asset Photo
                    Image.asset(
                      slide.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF151515)),
                    ),

                    // Atmospheric Dark Vignette Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.82),
                            Colors.black.withValues(alpha: 0.98),
                          ],
                          stops: const [0.0, 0.35, 0.72, 1.0],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top Header: Logo, Language Toggle & Skip Button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mini N8 Logo
                    const N8Logo.dark(size: 40, showText: false),

                    Row(
                      children: [
                        // Language Switcher Pill
                        GestureDetector(
                          onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.language, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  isArabic ? 'English' : 'العربية',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Skip Button
                        if (_currentPage < _slides.length - 1)
                          TextButton(
                            onPressed: _finishOnboarding,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text(
                              isArabic ? 'تخطي' : 'Skip',
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Content & Navigation
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Slide Title
                      Text(
                        isArabic ? _slides[_currentPage].titleAr : _slides[_currentPage].titleEn,
                        style: GoogleFonts.tajawal(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Slide Description
                      Text(
                        isArabic ? _slides[_currentPage].descAr : _slides[_currentPage].descEn,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Smooth Animated Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          final isSelected = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: isSelected ? 28 : 6,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // Primary CTA Button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 54),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                              : (isArabic ? 'متابعة' : 'Continue'),
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
