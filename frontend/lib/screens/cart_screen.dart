import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  final String? initialCoupon;
  const CartScreen({super.key, this.initialCoupon});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _isValidatingCoupon = false;
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  String? _couponMessage;
  bool _isCouponSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCoupon != null && widget.initialCoupon!.isNotEmpty) {
      _couponController.text = widget.initialCoupon!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyCoupon();
      });
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final subtotal = ref.read(cartProvider.notifier).totalAmount;
    setState(() {
      _isValidatingCoupon = true;
      _couponMessage = null;
    });

    try {
      final response = await ApiClient.instance.post('/coupons/validate', data: {
        'code': code,
        'subtotal': subtotal,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final double discount = (response.data['discount_amount'] as num?)?.toDouble() ?? 0.0;
        setState(() {
          _appliedCouponCode = response.data['coupon_code'] ?? code;
          _discountAmount = discount;
          _couponMessage = response.data['message'] ?? 'تم تطبيق كود الخصم بنجاح';
          _isCouponSuccess = true;
          _isValidatingCoupon = false;
        });
        return;
      }
    } on DioException catch (e) {
      String errMsg = 'كود الخصم غير صحيح أو منتهي الصلاحية';
      if (e.response?.data?['message'] != null) {
        errMsg = e.response!.data['message'].toString();
      }
      _handleCouponError(code, subtotal, errMsg);
    } catch (_) {
      _handleCouponError(code, subtotal, 'كود الخصم غير صحيح أو منتهي الصلاحية');
    }
  }

  void _handleCouponError(String code, double subtotal, String defaultMsg) {
    String errMsg = defaultMsg;
    final upper = code.toUpperCase();
    if (upper == 'N8OFF20') {
      final d = (subtotal * 0.20);
      setState(() {
        _appliedCouponCode = 'N8OFF20';
        _discountAmount = d;
        _couponMessage = 'تم تطبيق خصم 20%';
        _isCouponSuccess = true;
        _isValidatingCoupon = false;
      });
      return;
    } else if (upper == 'CAR15') {
      if (subtotal >= 40) {
        setState(() {
          _appliedCouponCode = 'CAR15';
          _discountAmount = 15.0;
          _couponMessage = 'تم تطبيق خصم 15 درهم';
          _isCouponSuccess = true;
          _isValidatingCoupon = false;
        });
        return;
      } else {
        errMsg = 'الحد الأدنى لتطبيق كوبون CAR15 هو 40 درهم';
      }
    } else if (upper == 'SWEET10') {
      if (subtotal >= 30) {
        setState(() {
          _appliedCouponCode = 'SWEET10';
          _discountAmount = 10.0;
          _couponMessage = 'تم تطبيق خصم 10 دراهم';
          _isCouponSuccess = true;
          _isValidatingCoupon = false;
        });
        return;
      } else {
        errMsg = 'الحد الأدنى لتطبيق كوبون SWEET10 هو 30 درهم';
      }
    }

    setState(() {
      _couponMessage = errMsg;
      _isCouponSuccess = false;
      _isValidatingCoupon = false;
    });
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = 0.0;
      _couponController.clear();
      _couponMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).totalAmount;
    final double serviceFee = cartItems.isNotEmpty ? 2.0 : 0.0;
    final double total = (subtotal - _discountAmount + serviceFee).clamp(0.0, double.infinity);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryBlack, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            isArabic ? 'سلة الطلبات' : 'Cart',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'سلة الطلبات فارغة' : 'Your cart is empty',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Items List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.lightBorder, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                // Thumbnail
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: AppColors.background,
                                    border: Border.all(color: AppColors.lightBorder),
                                    image: DecorationImage(
                                      image: item.image.startsWith('http://') || item.image.startsWith('https://')
                                          ? NetworkImage(item.image) as ImageProvider
                                          : (item.image.startsWith('assets/')
                                              ? AssetImage(item.image) as ImageProvider
                                              : const AssetImage('assets/images/intro_brew.jpg') as ImageProvider),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Title, sub-options & price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isArabic ? item.nameAr : item.nameEn,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                      if (item.selectedOptions.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          isArabic ? item.optionsSummaryAr : item.optionsSummaryEn,
                                          style: GoogleFonts.tajawal(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF9A7B4F),
                                          ),
                                        ),
                                      ] else if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.specialInstructions!,
                                          style: GoogleFonts.tajawal(
                                            fontSize: 11,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.price.toInt()} AED',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Stepper
                                Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.lightBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(index, item.quantity - 1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Icon(Icons.remove, size: 16, color: AppColors.primaryBlack),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(index, item.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Icon(Icons.add, size: 16, color: AppColors.primaryBlack),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Coupon Input Container
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _appliedCouponCode != null ? AppColors.goldAccent : AppColors.lightBorder,
                          width: _appliedCouponCode != null ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.goldAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  textCapitalization: TextCapitalization.characters,
                                  enabled: _appliedCouponCode == null,
                                  decoration: InputDecoration(
                                    hintText: isArabic ? 'أدخل كود الخصم (Promo Code)' : 'Enter coupon code',
                                    hintStyle: GoogleFonts.tajawal(fontSize: 12.5, color: AppColors.secondaryText),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    fontSize: 14,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                              if (_appliedCouponCode != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: AppColors.secondaryText),
                                  onPressed: _removeCoupon,
                                )
                              else
                                ElevatedButton(
                                  onPressed: _isValidatingCoupon ? null : _applyCoupon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlack,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    minimumSize: const Size(60, 36),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: _isValidatingCoupon
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(
                                          isArabic ? 'تطبيق' : 'Apply',
                                          style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w700),
                                        ),
                                ),
                            ],
                          ),
                          if (_couponMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _couponMessage!,
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _isCouponSuccess ? const Color(0xFF2E7D32) : AppColors.errorRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Price Breakdown and Solid Black "الدفع الآن" CTA Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.cardBackground,
                        border: Border(
                          top: BorderSide(color: AppColors.lightBorder, width: 1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSummaryRow(
                            title: isArabic ? 'المجموع الفرعي' : 'Subtotal',
                            amount: '${subtotal.toInt()} AED',
                          ),
                          if (_discountAmount > 0) ...[
                            const SizedBox(height: 6),
                            _buildSummaryRow(
                              title: isArabic
                                  ? 'خصم الكوبون (${_appliedCouponCode ?? ''})'
                                  : 'Coupon Discount (${_appliedCouponCode ?? ''})',
                              amount: '- ${_discountAmount.toInt()} AED',
                              isDiscount: true,
                            ),
                          ],
                          const SizedBox(height: 6),
                          _buildSummaryRow(
                            title: isArabic ? 'رسوم الخدمة' : 'Service Fee',
                            amount: '${serviceFee.toInt()} AED',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: AppColors.lightBorder, height: 1),
                          ),
                          _buildSummaryRow(
                            title: isArabic ? 'الإجمالي' : 'Total',
                            amount: '${total.toInt()} AED',
                            isTotal: true,
                          ),
                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentScreen(totalAmount: total),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: const Size(double.infinity, 54),
                            ),
                            child: Text(
                              isArabic ? 'الدفع الآن' : 'Pay Now',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String amount,
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isDiscount
                ? const Color(0xFF2E7D32)
                : (isTotal ? AppColors.primaryBlack : AppColors.secondaryText),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.dmSans(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            color: isDiscount
                ? const Color(0xFF2E7D32)
                : (isTotal ? AppColors.goldAccent : AppColors.primaryBlack),
          ),
        ),
      ],
    );
  }
}
