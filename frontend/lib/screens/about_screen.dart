import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/n8_logo.dart';

class AboutScreen extends ConsumerWidget {
  final int initialTabIndex;
  const AboutScreen({super.key, this.initialTabIndex = 0});

  static const String mapsUrl = 'https://maps.google.com/?q=Number+Eight+Specialty+Coffee+Al+Ain';
  static const String privacyPolicyUrl = 'https://no8.ae/privacy-policy';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
        initialIndex: initialTabIndex,
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
              isArabic ? 'معلومات التطبيق' : 'App Information',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlack,
              ),
            ),
            bottom: TabBar(
              indicatorColor: AppColors.goldAccent,
              indicatorWeight: 3,
              labelColor: AppColors.primaryBlack,
              unselectedLabelColor: AppColors.secondaryText,
              labelStyle: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: isArabic ? 'عن NUMBER EIGHT' : 'About N°8'),
                Tab(text: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Tab 1: About Us
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Center(child: N8Logo(size: 74)),
                    const SizedBox(height: 18),
                    Text(
                      'NUMBER EIGHT SPECIALTY COFFEE',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: AppColors.primaryBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic ? 'القهوة المختصة برؤية إماراتية أصيلة' : 'Specialty Coffee with an authentic UAE vision',
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Text(
                        isArabic
                            ? 'نحن في نمبر إيت (NUMBER EIGHT) نؤمن بأن كل كوب قهوة هو تجربة فريدة تبدأ من اختيار أجود محاصيل البن وتُحضّر بحرفية وعناية فائقة لتصل إليكم بأعلى معايير الجودة.\n\nتطبيقنا صُمم خصيصاً ليمنحكم تجربة طلب سلسة وفورية؛ سواء كنتم داخل المقهى لتناول مشروبكم (Dine-in)، أو طلب الاستلام بالسيارة (Car Pickup)، أو الاستلام السريع من الكاونتر، بالإضافة لمكافآت برنامج الولاء الحصرية.'
                            : 'At NUMBER EIGHT, we craft every cup from handpicked specialty beans roasted to perfection.\n\nOur app is built to provide a seamless ordering experience: whether you dine in, order to your car, or pick up from the counter, paired with exclusive loyalty rewards.',
                        style: GoogleFonts.tajawal(
                          fontSize: 13.5,
                          height: 1.75,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Branch & Official Location Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.location_on, color: Color(0xFF4285F4), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? 'الفرع الرسمي' : 'Official Branch',
                                      style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                                    ),
                                    Text(
                                      isArabic ? 'فرع الخبيصي — العين، دولة الإمارات' : 'Al Khabisi Branch — Al Ain, UAE',
                                      style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(mapsUrl),
                              icon: const Icon(Icons.map_outlined, size: 16, color: Color(0xFF4285F4)),
                              label: Text(
                                isArabic ? 'فتح الموقع في خرائط Google' : 'Open in Google Maps',
                                style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF4285F4)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF4285F4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Official Contact Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniContact(
                            icon: Icons.phone_outlined,
                            label: '0509002711',
                            onTap: () => _launchUrl('tel:0509002711'),
                          ),
                          Container(width: 1, height: 24, color: AppColors.lightBorder),
                          _buildMiniContact(
                            icon: Icons.chat_bubble_outline,
                            label: 'واتساب',
                            onTap: () => _launchUrl('https://wa.me/971509002711'),
                          ),
                          Container(width: 1, height: 24, color: AppColors.lightBorder),
                          _buildMiniContact(
                            icon: Icons.mail_outline,
                            label: 'info@no8.ae',
                            onTap: () => _launchUrl('mailto:info@no8.ae'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'الإصدار 1.0.1 (Build 9)',
                      style: GoogleFonts.dmSans(fontSize: 11.5, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Tab 2: Privacy Policy & Terms
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: AppColors.primaryBlack, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isArabic ? 'سياسة الخصوصية والشروط' : 'Privacy Policy & Terms',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isArabic
                                ? 'نلتزم في NUMBER EIGHT SPECIALTY COFFEE بحماية خصوصية زوارنا وعملائنا وفقاً للقوانين والأنظمة المعمول بها في دولة الإمارات العربية المتحدة.\n\n'
                                  '1. البيانات التي نجمعها:\n'
                                  '• الاسم ورقم الهاتف: لإنشاء حساب العميل وتأكيد الطلبات وإرسال إشعارات التجهيز ونقاط برنامج الولاء.\n'
                                  '• بيانات السيارة (رقم اللوحة، الإمارة، اللون، والموديل): يتم طلبها واستخدامها حصرياً عند اختيار خدمة الاستلام بالسيارة (Car Pickup) لتمكين الباريستا من إيصال طلبك بدقة وسرعة.\n'
                                  '• سجل الطلبات والمشتريات: لتسهيل إعادة الطلب وعرض الفواتير السابقة وتجميع أكواب المكافآت المجانية.\n\n'
                                  '2. معالجة المدفوعات وأمانها:\n'
                                  '• تتم جميع عمليات الدفع الإلكتروني (البطاقات البنكية، Apple Pay، Google Pay) عبر بوابة Stripe المشفرة والمعتمدة عالمياً بأعلى معايير الأمان المصرفي (PCI-DSS).\n'
                                  '• لا يقوم تطبيق NUMBER EIGHT بتخزين أي أرقام بطاقات ائتمانية أو مفاتيح سرية على خوادم الكافيه أو داخل أجهزة المستخدمين.\n\n'
                                  '3. مشاركة وسرية البيانات:\n'
                                  '• نحن لا نقوم ببيع أو تأجير أو مشاركة أي بيانات شخصية مع أي جهات خارجية لأغراض تجارية أو إعلانية.\n'
                                  '• تقتصر مشاركة البيانات التشغيلية فقط على شركاء الدفع المعتمدين لإتمام المعاملة بنجاح.\n\n'
                                  '4. إدارة الحساب وحذف البيانات:\n'
                                  '• يحق للعميل حذف حسابه وبياناته بالكامل في أي وقت ومباشرة عبر زر (حذف الحساب والبيانات) في شاشة الحساب.\n'
                                  '• عند تأكيد الحذف، يتم مسح بيانات الملف الشخصي ونقاط الولاء فوراً، مع الاحتفاظ بسجلات الفواتير المالية السابقة بشكل مجهول الهوية طبقاً للمتطلبات المحاسبية والضريبية الرسمية بدولة الإمارات.\n\n'
                                  '5. التواصل والاستفسارات:\n'
                                  'في حال وجود أي استفسار حول سياسة الخصوصية، يرجى التواصل معنا:\n'
                                  '• البريد الإلكتروني: info@no8.ae\n'
                                  '• الهاتف: 0509002711 / 0509004199\n'
                                  '• العنوان: فرع الخبيصي — العين — الإمارات العربية المتحدة'
                                : 'NUMBER EIGHT SPECIALTY COFFEE is committed to protecting your privacy in full compliance with UAE laws.\n\n'
                                  '1. Information We Collect:\n'
                                  '• Name & Phone Number: To maintain customer accounts, notify on order readiness, and manage loyalty rewards.\n'
                                  '• Vehicle Details (Plate Number, Emirate, Color, Model): Used strictly for Car Pickup orders to deliver your coffee directly to your vehicle.\n'
                                  '• Order History: To enable reordering, receipt viewing, and reward tracking.\n\n'
                                  '2. Payment Security:\n'
                                  '• Online payments via Card, Apple Pay, and Google Pay are handled securely by Stripe under PCI-DSS certification.\n'
                                  '• We never store credit card numbers or private payment keys on our servers or mobile devices.\n\n'
                                  '3. Data Confidentiality:\n'
                                  '• We do not sell, rent, or share personal data with unauthorized third parties.\n'
                                  '• Data is shared strictly with payment processing partners as needed to execute orders.\n\n'
                                  '4. Account & Data Deletion:\n'
                                  '• You can permanently delete your account and personal profile at any time from the Account screen.\n'
                                  '• Financial invoice records are retained anonymously to meet statutory UAE accounting and tax regulations.\n\n'
                                  '5. Contact Information:\n'
                                  '• Email: info@no8.ae\n'
                                  '• Phone: 0509002711 / 0509004199\n'
                                  '• Location: Al Khabisi Branch — Al Ain, UAE',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              height: 1.75,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(privacyPolicyUrl),
                              icon: const Icon(Icons.open_in_browser, size: 16, color: Color(0xFF2563EB)),
                              label: Text(
                                isArabic ? 'زيارة صفحة سياسة الخصوصية الرسمية' : 'Visit Official Privacy Policy Page',
                                style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF2563EB)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniContact({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.goldAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
            ),
          ],
        ),
      ),
    );
  }
}
