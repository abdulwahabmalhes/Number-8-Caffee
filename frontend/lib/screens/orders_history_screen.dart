import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../core/api_client.dart';
import 'phone_auth_screen.dart';
import 'order_tracking_screen.dart';
class OrdersHistoryScreen extends ConsumerStatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  ConsumerState<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends ConsumerState<OrdersHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchOrders());
  }

  Future<void> _fetchOrders() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await ApiClient.instance.get('/orders');
      if (res.data['success']) {
        if (mounted) {
          setState(() {
            _orders = res.data['orders'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isArabic ? 'سجل الطلبات' : 'Order History',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: !auth.isAuthenticated
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 64, color: AppColors.secondaryText),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'يرجى تسجيل الدخول لعرض سجل طلباتك' : 'Please login to view your order history',
                        style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                          ).then((_) => _fetchOrders());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isArabic ? 'تسجيل الدخول / حساب جديد' : 'Login / Register',
                          style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? Center(
                        child: Text(
                          isArabic ? 'لا توجد طلبات سابقة' : 'No previous orders',
                          style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.secondaryText),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return _buildOrderCard(order, isArabic);
                      },
                    ),
                  ),
      ),
    );
  }



  Widget _buildOrderCard(Map<String, dynamic> order, bool isArabic) {
    final status = order['status'];
    final isActive = ['new', 'accepted', 'preparing', 'ready'].contains(status);
    
    String displayStatus;
    Color statusColor;

    if (status == 'new' || status == 'accepted') {
      displayStatus = isArabic ? 'تم الاستلام' : 'Received';
      statusColor = Colors.orange;
    } else if (status == 'preparing') {
      displayStatus = isArabic ? 'قيد التحضير' : 'Preparing';
      statusColor = Colors.orange;
    } else if (status == 'ready') {
      displayStatus = isArabic ? 'جاهز للاستلام' : 'Ready';
      statusColor = Colors.green;
    } else if (status == 'delivered') {
      displayStatus = isArabic ? 'مكتمل' : 'Completed';
      statusColor = AppColors.successGreen;
    } else {
      displayStatus = status;
      statusColor = AppColors.secondaryText;
    }

    return InkWell(
      onTap: () {
        if (isActive) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(
                orderNumber: order['order_number'],
                initialMinutes: 8,
                initialSeconds: 0,
              ),
            ),
          ).then((_) => _fetchOrders());
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? AppColors.goldAccent : AppColors.lightBorder, width: isActive ? 1.5 : 1),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.goldAccent.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['order_number'],
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayStatus,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isArabic ? 'الإجمالي: ${order['grand_total']} درهم' : 'Total: ${order['grand_total']} AED',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlack,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timelapse, size: 16, color: AppColors.goldAccent),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'اضغط لتتبع الطلب' : 'Tap to track order',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldAccent,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
