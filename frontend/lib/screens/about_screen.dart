import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/n8_logo.dart';

class AboutScreen extends ConsumerWidget {
  final int initialTabIndex;
  const AboutScreen({super.key, this.initialTabIndex = 0});

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
              labelStyle: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700),
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Center(child: N8Logo(size: 80)),
                    const SizedBox(height: 24),
                    Text(
                      'NUMBER EIGHT SPECIALTY COFFEE',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppColors.primaryBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'القهوة المختصة برؤية إماراتية أصيلة' : 'Specialty Coffee with an authentic touch',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Text(
                        isArabic
                            ? 'نحن في نمبر إيت (NUMBER EIGHT) نؤمن بأن كل كوب قهوة هو تجربة فريدة تبدأ من اختيار أجود حبوب البن وتُحضّر بحرفية وعناية فائقة لتصل إليكم بأعلى معايير الجودة.\n\nتطبيقنا صُمم خصيصاً ليمنحكم تجربة طلب سلسة وفورية؛ سواء كنتم داخل المقهى، أو في سيارتكم، أو ترغبون بالاستلام السريع من الكاونتر، بالإضافة لمكافآت برنامج الولاء الحصرية.'
                            : 'At NUMBER EIGHT, we believe that every cup of coffee is a unique crafted experience, starting from the finest beans to the cup.\n\nOur app is tailored to give you seamless ordering: whether you are inside the cafe, ordering from your car, or picking up at the counter, with exclusive loyalty rewards.',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          height: 1.8,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'الإصدار 1.0.0 (Build 2026)',
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),

              // Tab 2: Privacy Policy
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'سياسة الخصوصية والشروط' : 'Privacy Policy & Terms',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isArabic
                            ? '1. جمع البيانات:\nنقوم بجمع بياناتك الأساسية (الاسم ورقم الهاتف) لغرض توثيق طلباتك وتتبع نقاط برنامج الولاء والجوائز وتسهيل عملية استلام الطلبات.\n\n2. سرية المعلومات:\nنحن نلتزم بحماية خصوصيتك وعدم مشاركة بياناتك الشخصية مع أي طرف ثالث غير مصرح له.\n\n3. أمان المدفوعات:\nتتم جميع المعاملات المالية عبر بوابات دفع آمنة ومشفرة وفق أعلى معايير الحماية المصرفية.\n\n4. التحديثات:\nيحق لإدارة NUMBER EIGHT تحديث بنود سياسة الخصوصية بما يتوافق مع الأنظمة المعمول بها في دولة الإمارات العربية المتحدة.'
                            : '1. Data Collection:\nWe collect basic information (Name & Phone) to process your orders, track loyalty points, and facilitate pickup.\n\n2. Confidentiality:\nWe are committed to securing your data and never sharing it with unauthorized third parties.\n\n3. Payment Security:\nAll transactions are encrypted through secure payment gateways.\n\n4. Updates:\nNUMBER EIGHT reserves the right to update privacy policies in accordance with UAE regulations.',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          height: 1.8,
                          color: AppColors.primaryBlack,
                        ),
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
}
