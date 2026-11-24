import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';

class N8Drawer extends ConsumerWidget {
  const N8Drawer({super.key});

  static const String cafePhone = '0509002711';
  static const String directCallPhone = '0509004199';
  static const String whatsappNumber = '971509002711';
  static const String emailAddress = 'info@no8.ae';
  static const String mapsUrl = 'https://maps.google.com/?q=Number+Eight+Specialty+Coffee+Al+Ain';

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showPrivacyPolicy(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isArabic ? 'سياسة الخصوصية والشروط' : 'Privacy Policy & Terms',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic
                      ? 'تطبيق NUMBER EIGHT يحترم خصوصيتك بالكامل ويخضع للأنظمة المعمول بها في دولة الإمارات العربية المتحدة.\n\n'
                        '1. جمع البيانات:\nنجمع بيانات الاسم ورقم الهاتف وتفاصيل السيارة (في طلبات الاستلام بالسيارة) لتسهيل تجهيز وتقديم طلبك بدقة.\n\n'
                        '2. أمان المدفوعات:\nتتم معالجة المدفوعات بأمان عبر بوابة Stripe المعتمدة وApple Pay دون تخزين أي أرقام بطاقات سرية على أجهزتنا أو خوادمنا.\n\n'
                        '3. حذف الحساب:\nيمكنك حذف حسابك وبياناتك نهائياً في أي وقت عبر شاشة الحساب، مع الاحتفاظ بالسجلات المحاسبية والضريبية وفق القوانين.\n\n'
                        'فرع الخبيصي — العين — الإمارات العربية المتحدة.\n'
                        'للاستفسار: info@no8.ae'
                      : 'NUMBER EIGHT respects your privacy in accordance with UAE laws.\n\n'
                        '1. Data Collection:\nWe collect name, phone, and vehicle details (for car pickup) to accurately prepare and deliver your orders.\n\n'
                        '2. Payment Security:\nPayments are securely processed via Stripe and Apple Pay. We do not store sensitive card data on our servers.\n\n'
                        '3. Account Deletion:\nYou can permanently delete your account and personal data anytime from the Account screen, with financial records retained as required by tax laws.\n\n'
                        'Al Khabisi Branch — Al Ain — UAE.\n'
                        'Contact: info@no8.ae',
                  style: GoogleFonts.tajawal(fontSize: 12.5, height: 1.6, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => _launchUrl('https://no8.ae/privacy-policy'),
                  child: Text(
                    isArabic ? 'عرض سياسة الخصوصية الكاملة على موقعنا ↗' : 'View Full Privacy Policy on Website ↗',
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
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
            // Header
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
                          isArabic ? 'القهوة المختصة — فرع الخبيصي، العين' : 'Specialty Coffee — Al Khabisi, Al Ain',
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

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Direct Call
                  _buildListTile(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: AppColors.gold,
                    title: isArabic ? 'الاتصال المباشر' : 'Direct Call',
                    subtitle: directCallPhone,
                    onTap: () => _launchUrl('tel:$directCallPhone'),
                  ),

                  // Cafe Phone
                  _buildListTile(
                    icon: Icons.storefront_rounded,
                    iconColor: AppColors.primaryBlack,
                    title: isArabic ? 'رقم الكافيه' : 'Cafe Phone',
                    subtitle: cafePhone,
                    onTap: () => _launchUrl('tel:$cafePhone'),
                  ),

                  // WhatsApp
                  _buildListTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF25D366),
                    title: isArabic ? 'واتساب الكافيه' : 'WhatsApp',
                    subtitle: cafePhone,
                    onTap: () => _launchUrl('https://wa.me/$whatsappNumber'),
                  ),

                  // Email
                  _buildListTile(
                    icon: Icons.mail_outline_rounded,
                    iconColor: const Color(0xFFEA4335),
                    title: isArabic ? 'البريد الإلكتروني' : 'Email',
                    subtitle: emailAddress,
                    onTap: () => _launchUrl('mailto:$emailAddress'),
                  ),

                  // Location (Google Maps)
                  _buildListTile(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFF4285F4),
                    title: isArabic ? 'فرع الخبيصي — العين' : 'Al Khabisi Branch',
                    subtitle: isArabic ? 'عرض الموقع على الخريطة' : 'View on Google Maps',
                    onTap: () => _launchUrl(mapsUrl),
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
                    'Version 1.0.2 (Build 10)',
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
