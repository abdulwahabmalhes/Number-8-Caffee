import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/n8_logo.dart';
import '../widgets/n8_bottom_nav.dart';
import 'table_qr_screen.dart';
import 'car_service_screen.dart';
import 'menu_screen.dart';
import 'orders_history_screen.dart';
import 'loyalty_tier_screen.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  ConsumerState<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends ConsumerState<ServiceSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top language switcher icon bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.language, color: AppColors.primaryBlack),
                      onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
                    ),
                    Text(
                      isArabic ? 'العربية' : 'English',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Official N8 Center Logo
                      const N8Logo(size: 84),

                      const SizedBox(height: 28),

                      // Greetings text
                      Text(
                        isArabic ? 'مرحباً بك في نمبر إيت' : 'Welcome to Number Eight',
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isArabic ? 'اختر طريقة طلبك' : 'Choose your ordering method',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Service Option 1: Inside Cafe / Table QR
                      _buildServiceCard(
                        context: context,
                        icon: Icons.local_cafe_outlined,
                        title: isArabic ? 'اطلب من داخل الكوفي' : 'Order Inside Café',
                        subtitle: isArabic ? 'اطلب من طاولتك' : 'Order from your table',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TableQrScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Service Option 2: Car Service
                      _buildServiceCard(
                        context: context,
                        icon: Icons.directions_car_outlined,
                        title: isArabic ? 'اطلب من السيارة' : 'Order from the Car',
                        subtitle: isArabic ? 'اطلب قبل وصولك' : 'Order before you arrive',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CarServiceScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Service Option 3: Counter Pickup
                      _buildServiceCard(
                        context: context,
                        icon: Icons.shopping_bag_outlined,
                        title: isArabic ? 'استلام من الكوفي' : 'Pickup from Café',
                        subtitle: isArabic ? 'اطلب واستلم من الكاونتر' : 'Order & pick up at the counter',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MenuScreen(orderType: 'pickup')),
                          );
                        },
                      ),

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

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightBorder, width: 1.2),
        ),
        child: Row(
          children: [
            // Outline Icon in rounded box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlack,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_left,
              color: AppColors.secondaryText,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
