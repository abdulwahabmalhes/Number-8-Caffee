import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
            _orders = res.data['orders'] ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOrderDetails(Map<String, dynamic> order, bool isArabic) {
    final status = order['status'] ?? 'new';
    final isActive = ['new', 'accepted', 'preparing', 'ready'].contains(status);
    final items = (order['items'] as List<dynamic>? ?? []);
    final vehicle = order['vehicle'];
    final table = order['table'];

    String displayStatus;
    Color statusColor;

    if (status == 'new' || status == 'accepted') {
      displayStatus = isArabic ? 'تم الاستلام' : 'Received';
      statusColor = Colors.orange;
    } else if (status == 'preparing') {
      displayStatus = isArabic ? 'قيد التحضير ☕' : 'Preparing';
      statusColor = Colors.orange;
    } else if (status == 'ready') {
      displayStatus = isArabic ? 'جاهز للاستلام ✓' : 'Ready';
      statusColor = Colors.green;
    } else if (status == 'delivered') {
      displayStatus = isArabic ? 'مكتمل ✓' : 'Delivered';
      statusColor = AppColors.successGreen;
    } else {
      displayStatus = status;
      statusColor = AppColors.secondaryText;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Top Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['order_number'] ?? '',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      Text(
                        order['created_at'] != null
                            ? order['created_at'].toString().substring(0, 16).replaceAll('T', ' ')
                            : '',
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ),

            const Divider(color: AppColors.lightBorder, height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Order Type Info (Table or Car)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          order['order_type'] == 'car'
                              ? Icons.directions_car_rounded
                              : Icons.table_restaurant_rounded,
                          color: AppColors.gold,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['order_type'] == 'car'
                                    ? (isArabic ? 'استلام من السيارة' : 'Car Pickup')
                                    : (isArabic
                                        ? 'طاولة رقم #${table != null ? table['table_number'] : '-'}'
                                        : 'Table #${table != null ? table['table_number'] : '-'}'),
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              if (order['order_type'] == 'car' && vehicle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${vehicle['plate_emirate'] ?? ''} ${vehicle['plate_number'] ?? ''} • ${vehicle['vehicle_model'] ?? ''} (${vehicle['vehicle_color'] ?? ''})',
                                  style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.secondaryText),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Items Section
                  Text(
                    isArabic ? 'الأصناف والإضافات' : 'Items & Add-ons',
                    style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryBlack),
                  ),
                  const SizedBox(height: 10),

                  ...items.map((item) {
                    final product = item['product'];
                    final prodName = product != null
                        ? (isArabic ? (product['name_ar'] ?? product['name_en']) : product['name_en'])
                        : (isArabic ? 'منتج قهوة' : 'Coffee Item');
                    final options = (item['options'] as List<dynamic>? ?? []);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['quantity']}x $prodName',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                              Text(
                                '${item['total_price']} AED',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ],
                          ),
                          if (options.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: options.map((optItem) {
                                final opt = optItem['option'];
                                final optName = opt != null
                                    ? (isArabic ? opt['name_ar'] : opt['name_en'])
                                    : '';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '• $optName',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 11,
                                      color: const Color(0xFF9A7B4F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          if (item['special_instructions'] != null &&
                              item['special_instructions'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item['special_instructions'],
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Simplified Tax Invoice Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic ? 'فاتورة ضريبية مبسطة' : 'Simplified Tax Invoice',
                              style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'TRN: 100293847500003',
                              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.lightBorder, height: 18),
                        _buildInvoiceRow(
                          isArabic ? 'المجموع الفرعي' : 'Subtotal',
                          '${order['subtotal'] ?? order['grand_total']} AED',
                          isArabic,
                        ),
                        const SizedBox(height: 6),
                        _buildInvoiceRow(
                          isArabic ? 'ضريبة القيمة المضافة (5% مشمولة)' : 'VAT (5% Included)',
                          '${((double.tryParse(order['grand_total'].toString()) ?? 0) * 0.05).toStringAsFixed(2)} AED',
                          isArabic,
                        ),
                        const SizedBox(height: 6),
                        _buildInvoiceRow(
                          isArabic ? 'طريقة الدفع' : 'Payment Method',
                          (order['payment_method'] ?? 'Apple Pay').toString().toUpperCase(),
                          isArabic,
                        ),
                        const Divider(color: AppColors.lightBorder, height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic ? 'المبلغ الإجمالي' : 'Total Amount',
                              style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${order['grand_total']} AED',
                              style: GoogleFonts.dmSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Button: View In-App Official Thermal Tax Invoice
                  OutlinedButton.icon(
                    onPressed: () => _showInAppThermalReceipt(context, order, isArabic),
                    icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlack, size: 20),
                    label: Text(
                      isArabic ? 'عرض الفاتورة الضريبية الرسمية 🧾' : 'View Official Tax Invoice 🧾',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                  if (isActive) ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
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
                      },
                      icon: const Icon(Icons.location_searching_rounded, color: Colors.white, size: 20),
                      label: Text(
                        isArabic ? 'تتبع حالة الطلب مباشرة ➔' : 'Track Order Live ➔',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.secondaryText),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
        ),
      ],
    );
  }

  void _showInAppThermalReceipt(BuildContext context, Map<String, dynamic> order, bool isArabic) {
    final items = (order['items'] as List<dynamic>? ?? []);
    final vehicle = order['vehicle'];
    final table = order['table'];
    final grandTotal = double.tryParse(order['grand_total']?.toString() ?? '0') ?? 0.0;
    final subtotal = double.tryParse(order['subtotal']?.toString() ?? '$grandTotal') ?? grandTotal;
    final vat = grandTotal * 0.05;
    final orderNum = order['order_number'] ?? '#NE1278';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Close button
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.black),
                    ),
                  ),
                ),

                // Brand Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'NUMBER EIGHT',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SPECIALTY COFFEE — القهوة المختصة',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF444444),
                        ),
                      ),
                      Text(
                        'فرع الخبيصي — العين — الإمارات',
                        style: GoogleFonts.tajawal(fontSize: 10, color: const Color(0xFF666666)),
                      ),
                      Text(
                        'الرقم الضريبي TRN: 100293847500003',
                        style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF666666)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EFEA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'فاتورة ضريبية مبسطة / TAX INVOICE',
                          style: GoogleFonts.tajawal(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                _buildDashedLine(),
                const SizedBox(height: 8),

                // Order Meta
                _buildThermalRow('رقم الطلب / Order:', orderNum, isBold: true),
                _buildThermalRow(
                  'التاريخ / Date:',
                  order['created_at'] != null
                      ? order['created_at'].toString().substring(0, 16).replaceAll('T', ' ')
                      : DateTime.now().toString().substring(0, 16),
                ),
                _buildThermalRow(
                  'نوع الطلب / Type:',
                  order['order_type'] == 'car'
                      ? 'سيارة (${vehicle != null ? "${vehicle['plate_emirate']} ${vehicle['plate_number']}" : "-"})'
                      : 'طاولة #${table != null ? table['table_number'] : "-"}',
                ),
                _buildThermalRow(
                  'الدفع / Payment:',
                  '${(order['payment_method'] ?? "Apple Pay").toString().toUpperCase()} (${order['payment_status'] == "paid" ? "مدفوع ✓" : "عند الكاشير"})',
                ),

                const SizedBox(height: 8),
                _buildDashedLine(),
                const SizedBox(height: 8),

                // Items list
                ...items.map((item) {
                  final prod = item['product'];
                  final prodName = prod != null ? (prod['name_en'] ?? prod['name_ar']) : 'Specialty Drink';
                  final prodNameAr = prod != null ? (prod['name_ar'] ?? '') : '';
                  final options = (item['options'] as List<dynamic>? ?? []);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['quantity']}x $prodName',
                                style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${item['total_price']} AED',
                              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        if (prodNameAr.isNotEmpty)
                          Text(
                            prodNameAr,
                            style: GoogleFonts.tajawal(fontSize: 10, color: const Color(0xFF666666)),
                          ),
                        if (options.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              options.map((o) {
                                final opt = o['option'];
                                return opt != null ? '+ ${opt['name_en'] ?? opt['name_ar']}' : '';
                              }).where((s) => s.isNotEmpty).join(' • '),
                              style: GoogleFonts.dmSans(
                                fontSize: 9.5,
                                color: const Color(0xFF8B6B38),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                _buildDashedLine(),
                const SizedBox(height: 8),

                // Totals
                _buildThermalRow('المجموع الفرعي / Subtotal:', '${subtotal.toStringAsFixed(2)} AED'),
                _buildThermalRow('الضريبة / VAT (5%):', '${vat.toStringAsFixed(2)} AED'),
                const SizedBox(height: 4),
                _buildDashedLine(),
                const SizedBox(height: 6),
                _buildThermalRow(
                  'المبلغ الإجمالي / Total:',
                  '${grandTotal.toStringAsFixed(2)} AED',
                  isBold: true,
                  fontSize: 13,
                ),
                const SizedBox(height: 6),
                _buildDashedLine(),

                // QR Code
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=NUMBER_EIGHT_$orderNum&color=000000&bgcolor=FFFFFF',
                      width: 84,
                      height: 84,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 70),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'شكراً لزيارتكم • Thank you for your visit',
                    style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF444444)),
                  ),
                ),

                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isArabic ? 'إغلاق الفاتورة' : 'Close Invoice',
                    style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.constrainWidth() / 8).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: 4,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF888888)),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildThermalRow(String label, String value, {bool isBold = false, double fontSize = 11}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isArabic ? 'سجل الطلبات' : 'Order History',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlack))
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
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
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
    final status = order['status'] ?? 'new';
    final isActive = ['new', 'accepted', 'preparing', 'ready'].contains(status);

    String displayStatus;
    Color statusColor;

    if (status == 'new' || status == 'accepted') {
      displayStatus = isArabic ? 'تم الاستلام' : 'Received';
      statusColor = Colors.orange;
    } else if (status == 'preparing') {
      displayStatus = isArabic ? 'قيد التحضير ☕' : 'Preparing';
      statusColor = Colors.orange;
    } else if (status == 'ready') {
      displayStatus = isArabic ? 'جاهز للاستلام ✓' : 'Ready';
      statusColor = Colors.green;
    } else if (status == 'delivered') {
      displayStatus = isArabic ? 'مكتمل ✓' : 'Completed';
      statusColor = AppColors.successGreen;
    } else {
      displayStatus = status;
      statusColor = AppColors.secondaryText;
    }

    final itemsCount = (order['items'] as List<dynamic>? ?? []).length;

    return InkWell(
      onTap: () => _showOrderDetails(order, isArabic),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.lightBorder,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order['order_number'] ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order['order_type'] == 'car'
                            ? (isArabic ? 'سيارة 🚗' : 'Car')
                            : (isArabic ? 'طاولة' : 'Table'),
                        style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic
                      ? '$itemsCount أصناف • ${order['grand_total']} درهم'
                      : '$itemsCount items • ${order['grand_total']} AED',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isArabic ? 'تفاصيل الطلب والفاتورة' : 'Details & Invoice',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.gold),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
