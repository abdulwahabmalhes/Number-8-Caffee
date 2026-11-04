import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import 'menu_screen.dart';
import 'orders_history_screen.dart';
import 'loyalty_tier_screen.dart';
import 'profile_screen.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  int _currentNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryBlack),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            isArabic ? 'العروض' : 'Offers & Specials',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                  child: Column(
                    children: [
                      // Card 1: 20% Discount (Dark Luxury Card matching reference)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF2C2C2C)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'خصم 20%' : '20% OFF',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic
                                        ? 'على جميع المشروبات الباردة\nمن 4 مساءً - 6 مساءً'
                                        : 'On all cold drinks\nfrom 4 PM to 6 PM',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E2E2E),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(110, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      isArabic ? 'استخدم العرض' : 'Claim Offer',
                                      style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=300&auto=format&fit=crop',
                                width: 100,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Card 2: New V60 Specialty (Clean Light Card matching reference)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'جديد V60' : 'NEW V60',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic
                                        ? 'جرب نكهتنا الجديدة\nمن إثيوبيا'
                                        : 'Experience our new\nEthiopian single origin',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlack,
                                      minimumSize: const Size(110, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      isArabic ? 'اطلب الآن' : 'Order Now',
                                      style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1498603536246-15572faa67a6?q=80&w=300&auto=format&fit=crop',
                                width: 100,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Card 3: Referral Banner matching reference
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'ادعُ صديقك' : 'Invite a Friend',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic
                                        ? 'واحصل على 20 نقطة لكل صديق'
                                        : 'And get 20 bonus points for each friend',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isArabic ? 'تم نسخ رابط الدعوة الخاص بك' : 'Referral link copied',
                                          ),
                                          backgroundColor: AppColors.primaryBlack,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlack,
                                      minimumSize: const Size(90, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      isArabic ? 'دعوة' : 'Invite',
                                      style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background,
                                border: Border.all(color: AppColors.lightBorder),
                              ),
                              child: const Icon(Icons.people_alt_outlined, size: 36, color: AppColors.primaryBlack),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              N8BottomNav(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() => _currentNavIndex = index);
                  if (index == 0) {
                    Navigator.pop(context);
                  } else if (index == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()));
                  } else if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyTierScreen()));
                  } else if (index == 3) {
                    // Current
                  } else if (index == 4) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
