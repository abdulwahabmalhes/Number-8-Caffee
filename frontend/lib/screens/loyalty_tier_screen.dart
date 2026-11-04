import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';
import 'orders_history_screen.dart';

class LoyaltyTierScreen extends ConsumerStatefulWidget {
  const LoyaltyTierScreen({super.key});

  @override
  ConsumerState<LoyaltyTierScreen> createState() => _LoyaltyTierScreenState();
}

class _LoyaltyTierScreenState extends ConsumerState<LoyaltyTierScreen> {
  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.primaryBlack, // Luxury dark background matching reference
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlack,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'N8 REWARDS',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Luxury Dark Gold Tier Card matching reference
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF333333), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tier Avatar & Points
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFC6903C).withValues(alpha: 0.2),
                                        border: Border.all(color: const Color(0xFFC6903C), width: 1.5),
                                      ),
                                      child: const Icon(
                                        Icons.workspace_premium,
                                        color: Color(0xFFC6903C),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isArabic ? 'المستوى الحالي' : 'Current Tier',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 11,
                                            color: Colors.white60,
                                          ),
                                        ),
                                        Text(
                                          'GOLD',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFD4AF37),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      isArabic ? 'النقاط المتاحة' : 'Available Points',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 11,
                                        color: Colors.white60,
                                      ),
                                    ),
                                    Text(
                                      isArabic ? '820 نقطة' : '820 PTS',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Gold Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: const LinearProgressIndicator(
                                value: 0.82,
                                minHeight: 6,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                isArabic ? '180 نقطة للوصول للمستوى التالي' : '180 pts to next level',
                                style: GoogleFonts.tajawal(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Section: Benefits (المزايا)
                      Center(
                        child: Text(
                          isArabic ? 'المزايا' : 'Tier Benefits',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Benefit 1: 9th Cup Free
                      _buildBenefitCard(
                        icon: Icons.coffee_outlined,
                        title: isArabic
                            ? 'كل 8 أكواب الكوب التاسع مجاناً'
                            : 'Buy 8 cups and get the 9th free',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoyaltyPunchScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Benefit 2: 10% discount
                      _buildBenefitCard(
                        icon: Icons.percent_outlined,
                        title: isArabic
                            ? 'خصم 10% على جميع الطلبات'
                            : '10% discount on all orders',
                      ),
                      const SizedBox(height: 12),

                      // Benefit 3: Birthday Drink
                      _buildBenefitCard(
                        icon: Icons.card_giftcard_outlined,
                        title: isArabic
                            ? 'كوب مجاني في عيد الميلاد'
                            : 'Free beverage on your birthday',
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF333333), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2A2E),
                border: Border.all(color: const Color(0xFF444444)),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}
