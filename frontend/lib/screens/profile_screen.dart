import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/user_data_provider.dart';
import 'orders_history_screen.dart';
import 'favorites_screen.dart';
import 'addresses_screen.dart';
import 'vehicles_screen.dart';
import 'about_screen.dart';
import 'support_screen.dart';
import 'phone_auth_screen.dart';
import '../widgets/n8_popup.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _ordersCount = 0;
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchOrdersCount());
  }

  Future<void> _fetchOrdersCount() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      if (mounted) setState(() => _isLoadingOrders = false);
      return;
    }

    try {
      final res = await ApiClient.instance.get('/orders');
      if (res.data['success'] && mounted) {
        final List orders = res.data['orders'] ?? [];
        setState(() {
          _ordersCount = orders.length;
          _isLoadingOrders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingOrders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final auth = ref.watch(authProvider);
    final favs = ref.watch(favoritesProvider);
    final userData = ref.watch(userDataProvider);

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
            isArabic ? 'حسابي' : 'My Account',
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
                      // User Info Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppColors.lightBorder, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: ClipOval(
                                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              auth.user?['name'] ?? (isArabic ? 'مستخدم زائر' : 'Guest User'),
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.user?['phone'] ?? (isArabic ? 'غير مسجل' : 'Not Registered'),
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            if (!auth.isAuthenticated) ...[
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                                  ).then((_) => _fetchOrdersCount());
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primaryBlack),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  isArabic ? 'تسجيل الدخول / إنشاء حساب' : 'Login / Register',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 3-Card Quick Actions Grid (Orders, Favorites, Vehicles - Addresses removed)
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.95,
                        children: [
                          // 1. My Orders
                          _buildGridActionCard(
                            icon: Icons.shopping_bag_outlined,
                            title: isArabic ? 'طلباتي' : 'My Orders',
                            subtitle: _isLoadingOrders
                                ? '...'
                                : isArabic
                                    ? '$_ordersCount طلب'
                                    : '$_ordersCount orders',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()),
                            ).then((_) => _fetchOrdersCount()),
                          ),

                          // 2. Favorites
                          _buildGridActionCard(
                            icon: Icons.favorite_border,
                            title: isArabic ? 'المفضلة' : 'Favorites',
                            subtitle: isArabic
                                ? '${favs.length} منتجات'
                                : '${favs.length} items',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                            ),
                          ),

                          // 3. Vehicles
                          _buildGridActionCard(
                            icon: Icons.directions_car_outlined,
                            title: isArabic ? 'سياراتي' : 'Vehicles',
                            subtitle: isArabic
                                ? '${userData.vehicles.length} سيارات'
                                : '${userData.vehicles.length} vehicles',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Settings & Details List Items
                      Material(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.lightBorder, width: 1.2),
                          ),
                          child: Column(
                            children: [
                              // About Us
                              _buildListTile(
                                icon: Icons.info_outline,
                                title: isArabic ? 'عن NUMBER EIGHT' : 'About NUMBER EIGHT',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AboutScreen(initialTabIndex: 0)),
                                ),
                              ),
                              const Divider(color: AppColors.lightBorder, height: 1, indent: 56),

                              // Privacy Policy
                              _buildListTile(
                                icon: Icons.privacy_tip_outlined,
                                title: isArabic ? 'سياسة الخصوصية والشروط' : 'Privacy Policy & Terms',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AboutScreen(initialTabIndex: 1)),
                                ),
                              ),
                              const Divider(color: AppColors.lightBorder, height: 1, indent: 56),

                              // Support & WhatsApp
                              _buildListTile(
                                icon: Icons.headset_mic_outlined,
                                title: isArabic ? 'المساعدة والدعم وواتساب' : 'Help, Support & WhatsApp',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                                ),
                              ),
                              const Divider(color: AppColors.lightBorder, height: 1, indent: 56),

                              // Settings & Language
                              _buildListTile(
                                icon: Icons.language_outlined,
                                title: isArabic ? 'اللغة / Language' : 'Language / اللغة',
                                trailingText: isArabic ? 'العربية' : 'English',
                                onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                              ),

                              if (auth.isAuthenticated) ...[
                                const Divider(color: AppColors.lightBorder, height: 1, indent: 56),
                                ListTile(
                                  leading: const Icon(Icons.logout, color: Colors.orange, size: 22),
                                  title: Text(
                                    isArabic ? 'تسجيل الخروج' : 'Logout',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  onTap: () async {
                                    await ref.read(authProvider.notifier).logout();
                                    setState(() {
                                      _ordersCount = 0;
                                    });
                                  },
                                ),
                                const Divider(color: AppColors.lightBorder, height: 1, indent: 56),
                                ListTile(
                                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red, size: 22),
                                  title: Text(
                                    isArabic ? 'حذف الحساب والبيانات' : 'Delete Account & Data',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                  subtitle: Text(
                                    isArabic ? 'حذف الحساب نهائياً ومسح كافة بياناتك' : 'Permanently remove your account and data',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 11,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  onTap: () {
                                    N8Popup.showConfirm(
                                      context: context,
                                      title: isArabic ? 'حذف الحساب نهائياً' : 'Delete Account Permanently',
                                      message: isArabic
                                          ? 'هل أنت متأكد من رغبتك بحذف حسابك؟ سيتم حذف جميع بياناتك وسجل نقاط برنامج الولاء بشكل دائم ولا يمكن التراجع عن هذا الإجراء.'
                                          : 'Are you sure you want to delete your account? All your personal data and loyalty points will be permanently deleted and cannot be undone.',
                                      confirmBtnText: isArabic ? 'نعم، احذف حسابي' : 'Yes, Delete My Account',
                                      cancelBtnText: isArabic ? 'تراجع' : 'Cancel',
                                      isDestructive: true,
                                      onConfirm: () async {
                                        final success = await ref.read(authProvider.notifier).deleteAccount();
                                        if (mounted) {
                                          setState(() => _ordersCount = 0);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? (isArabic ? 'تم حذف حسابك بنجاح' : 'Account deleted successfully')
                                                    : (isArabic ? 'حدث خطأ أثناء حذف الحساب' : 'Error deleting account'),
                                                style: GoogleFonts.tajawal(),
                                              ),
                                              backgroundColor: success ? Colors.black87 : Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
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

  Widget _buildGridActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lightBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlack, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlack,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlack, size: 22),
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlack,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_left, color: AppColors.secondaryText, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
