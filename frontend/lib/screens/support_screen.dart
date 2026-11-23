import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  // Official Verified Contact Details
  static const String cafePhone = '0509002711';
  static const String directCallPhone = '0509004199';
  static const String whatsappNumber = '971509002711';
  static const String emailAddress = 'info@no8.ae';
  static const String websiteUrl = 'https://no8.ae';
  static const String mapsUrl = 'https://maps.google.com/?q=Number+Eight+Specialty+Coffee+Al+Ain';
  static const String instagramUrl = 'https://instagram.com/numbereight.ae';
  static const String tiktokUrl = 'https://tiktok.com/@numbereight.ae';

  Future<void> _launchUrlHelper(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: $urlString')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            isArabic ? 'المساعدة والدعم' : 'Help & Support',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Support Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.headset_mic_outlined, color: AppColors.goldAccent, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'فريق خدمة العملاء' : 'Customer Care',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArabic ? 'جاهزون لخدمتك ومساعدتك دائماً' : 'Always here to assist you',
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  isArabic ? 'قنوات التواصل المباشر' : 'Direct Channels',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),

                // Direct Call Button
                _buildContactTile(
                  icon: Icons.phone_in_talk_rounded,
                  iconColor: AppColors.goldAccent,
                  title: isArabic ? 'الاتصال المباشر' : 'Direct Call',
                  subtitle: directCallPhone,
                  onTap: () => _launchUrlHelper(context, 'tel:$directCallPhone'),
                ),

                const SizedBox(height: 12),

                // Cafe Phone Button
                _buildContactTile(
                  icon: Icons.storefront_rounded,
                  iconColor: AppColors.primaryBlack,
                  title: isArabic ? 'رقم الكافيه' : 'Cafe Phone',
                  subtitle: cafePhone,
                  onTap: () => _launchUrlHelper(context, 'tel:$cafePhone'),
                ),

                const SizedBox(height: 12),

                // WhatsApp Button
                _buildContactTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: const Color(0xFF25D366),
                  title: isArabic ? 'محادثة عبر واتساب' : 'Chat via WhatsApp',
                  subtitle: cafePhone,
                  onTap: () => _launchUrlHelper(context, 'https://wa.me/$whatsappNumber'),
                ),

                const SizedBox(height: 12),

                // Email Button
                _buildContactTile(
                  icon: Icons.mail_outline_rounded,
                  iconColor: const Color(0xFFEA4335),
                  title: isArabic ? 'البريد الإلكتروني' : 'Email Us',
                  subtitle: emailAddress,
                  onTap: () => _launchUrlHelper(context, 'mailto:$emailAddress'),
                ),

                const SizedBox(height: 28),

                Text(
                  isArabic ? 'موقع الفرع' : 'Branch Location',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),

                // Branch Location / Google Maps Button
                _buildContactTile(
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF4285F4),
                  title: isArabic ? 'فرع الخبيصي — العين' : 'Al Khabisi Branch — Al Ain',
                  subtitle: isArabic ? 'فتح الموقع في خرائط Google' : 'Open in Google Maps',
                  onTap: () => _launchUrlHelper(context, mapsUrl),
                ),

                const SizedBox(height: 28),

                Text(
                  isArabic ? 'تابعنا على مواقع التواصل' : 'Follow Our Socials',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),

                // Instagram
                _buildContactTile(
                  icon: Icons.camera_alt_outlined,
                  iconColor: const Color(0xFFE1306C),
                  title: 'Instagram',
                  subtitle: '@numbereight.ae',
                  onTap: () => _launchUrlHelper(context, instagramUrl),
                ),

                const SizedBox(height: 12),

                // TikTok
                _buildContactTile(
                  icon: Icons.music_note_outlined,
                  iconColor: Colors.black,
                  title: 'TikTok',
                  subtitle: '@numbereight.ae',
                  onTap: () => _launchUrlHelper(context, tiktokUrl),
                ),

                const SizedBox(height: 12),

                // Website
                _buildContactTile(
                  icon: Icons.language_outlined,
                  iconColor: AppColors.goldAccent,
                  title: isArabic ? 'الموقع الإلكتروني' : 'Official Website',
                  subtitle: 'no8.ae',
                  onTap: () => _launchUrlHelper(context, websiteUrl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.secondaryText, size: 20),
          ],
        ),
      ),
    );
  }
}
