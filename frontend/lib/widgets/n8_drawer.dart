import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';

class N8Drawer extends ConsumerWidget {
  const N8Drawer({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showPrivacyPolicy(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isArabic ? 'سياسة الخصوصية والشروط' : 'Privacy Policy & Terms',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Text(
            isArabic
                ? 'تطبيق NUMBER EIGHT يحترم خصوصيتك بالكامل. البيانات المستخدمة (رقم الهاتف، تفاصيل السيارة لطلبات الاستلام) تُستخدم حصرياً لإتمام طلبات القهوة وتحسين تجربتك داخل الفرع وخدمة السيارات. لا يتم مشاركة بياناتك مع أي طرف ثالث.\n\nفرع الخبيصي - العين - الإمارات العربية المتحدة.'
                : 'NUMBER EIGHT respects your privacy. Information collected (phone number, vehicle details for car pickup) is used solely to process your coffee orders and deliver a seamless dine-in and car pickup experience. Your data is never shared with third parties.\n\nAl Khabisi Branch - Al Ain - UAE.',
            style: GoogleFonts.tajawal(fontSize: 13, height: 1.5, color: AppColors.secondaryText),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isArabic ? 'إغلاق' : 'Close',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header with smaller, more refined fonts
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NUMBER EIGHT',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic ? 'القهوة المختصة — العين' : 'Specialty Coffee — Al Ain',
                          style: GoogleFonts.tajawal(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Navigation Items (Exact User Contact Details & Smaller Typography)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Phone Call (Call 0565956180)
                  _buildListTile(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: AppColors.gold,
                    title: isArabic ? 'الاتصال المباشر' : 'Call Us',
                    subtitle: '0565956180',
                    onTap: () => _launchUrl('tel:0565956180'),
                  ),

                  // WhatsApp Contact (+971 56 595 6180)
                  _buildListTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF25D366),
                    title: isArabic ? 'واتساب الكافيه' : 'WhatsApp',
                    subtitle: '+971 56 595 6180',
                    onTap: () => _launchUrl('https://wa.me/971565956180'),
                  ),

                  // Email (saeed123_2007@hotmail.com)
                  _buildListTile(
                    icon: Icons.mail_outline_rounded,
                    iconColor: const Color(0xFFEA4335),
                    title: isArabic ? 'البريد الإلكتروني' : 'Email',
                    subtitle: 'saeed123_2007@hotmail.com',
                    onTap: () => _launchUrl('mailto:saeed123_2007@hotmail.com'),
                  ),

                  // Instagram
                  _buildListTile(
                    icon: Icons.camera_alt_outlined,
                    iconColor: const Color(0xFFE1306C),
                    title: 'Instagram',
                    subtitle: '@numbereight.ae',
                    onTap: () => _launchUrl('https://instagram.com/numbereight.ae'),
                  ),

                  // TikTok
                  _buildListTile(
                    icon: Icons.music_note_rounded,
                    iconColor: AppColors.primaryBlack,
                    title: 'TikTok',
                    subtitle: '@numbereight.ae',
                    onTap: () => _launchUrl('https://www.tiktok.com/@numbereight.ae'),
                  ),

                  // Website
                  _buildListTile(
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: isArabic ? 'الموقع الإلكتروني' : 'Website',
                    subtitle: 'no8.ae',
                    onTap: () => _launchUrl('https://no8.ae'),
                  ),

                  const Divider(color: AppColors.lightBorder, height: 20),

                  // Language Switcher
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.translate_rounded, color: AppColors.primaryBlack, size: 17),
                    ),
                    title: Text(
                      isArabic ? 'اللغة / Language' : 'Language / اللغة',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    trailing: Text(
                      isArabic ? 'English' : 'العربية',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        fontSize: 12.5,
                      ),
                    ),
                    onTap: () {
                      ref.read(localeProvider.notifier).toggleLocale();
                      Navigator.pop(context);
                    },
                  ),

                  // Privacy Policy
                  _buildListTile(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.secondaryText,
                    title: isArabic ? 'سياسة الخصوصية والشروط' : 'Privacy Policy & Terms',
                    subtitle: isArabic ? 'نظام iOS و Android' : 'iOS & Android Compliant',
                    onTap: () => _showPrivacyPolicy(context, isArabic),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Text(
                    'NUMBER EIGHT COFFEE © 2026',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version 1.0.1 (Build 7)',
                    style: GoogleFonts.dmSans(
                      fontSize: 9.5,
                      color: AppColors.secondaryText.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 17),
      ),
      title: Text(
        title,
        style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.secondaryText),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }
}
