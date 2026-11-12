import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';

class N8BottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const N8BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final bgColor = isDark ? const Color(0xFF101010) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222222) : AppColors.lightBorder;
    final activeColor = isDark ? AppColors.goldAccent : AppColors.primaryBlack;
    final inactiveColor = isDark ? Colors.white54 : const Color(0xFFA09C96);

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        labelAr: 'الرئيسية',
        labelEn: 'Home',
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        labelAr: 'الطلبات',
        labelEn: 'Orders',
      ),
      _NavItem(
        icon: Icons.local_offer_outlined,
        activeIcon: Icons.local_offer,
        labelAr: 'العروض',
        labelEn: 'Offers',
      ),
      _NavItem(
        icon: Icons.card_giftcard_outlined,
        activeIcon: Icons.card_giftcard,
        labelAr: 'المكافآت',
        labelEn: 'Rewards',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        labelAr: 'حسابي',
        labelEn: 'Account',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? item.labelAr : item.labelEn,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelAr;
  final String labelEn;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelAr,
    required this.labelEn,
  });
}
