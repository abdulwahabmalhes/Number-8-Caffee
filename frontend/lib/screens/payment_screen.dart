import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import '../providers/auth_provider.dart';
import 'phone_auth_screen.dart';
import 'order_tracking_screen.dart';

enum PaymentType { stripe, n8Wallet, cashOnDelivery }

class PaymentScreen extends ConsumerStatefulWidget {
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentType _selectedType = PaymentType.stripe;
  bool _isProcessing = false;
  String _processingMessage = '';

  // Stripe Configuration Status
  bool _isStripeConfigured = true;
  bool _isStripeLive = false;
  String _publishableKey = 'pk_test_51U84ak51MrrQCtiRqL8XS3ZmSY0XsiF4FeSdUFPiFAruTATGpA84zgQW38JKI6uXNBShjrZEzeJhbyxg494aJ7KB00d5yCeO6s';

  @override
  void initState() {
    super.initState();
    _loadStripeConfig();
  }

  Future<void> _loadStripeConfig() async {
    try {
      final res = await ApiClient.instance.get('/stripe/config');
      if (res.data != null && res.data['success'] == true && mounted) {
        setState(() {
          _isStripeConfigured = res.data['is_configured'] ?? false;
          _isStripeLive = res.data['is_live'] ?? false;
          _publishableKey = res.data['publishable_key'] ?? '';
        });
      }
    } catch (_) {
      // Backend might still use default environment settings
    }
  }

  void _showStripeKeySettingsDialog() {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final pkCtrl = TextEditingController(text: _publishableKey);
    final skCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF635BFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.vpn_key_rounded, color: Color(0xFF635BFF), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isArabic ? 'إعدادات مفاتيح Stripe' : 'Stripe API Keys Setup',
                        style: GoogleFonts.tajawal(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isArabic
                    ? 'أدخل مفاتيح الربط الخاصة بحسابك في Stripe لتفعيل الدفع المباشر'
                    : 'Enter your Stripe API Keys to activate real-time card checkout',
                style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),

              // Publishable Key
              TextField(
                controller: pkCtrl,
                decoration: InputDecoration(
                  labelText: isArabic ? 'المفتاح العام (Publishable Key)' : 'Publishable Key (pk_...)',
                  hintText: 'pk_live_... / pk_test_...',
                  prefixIcon: const Icon(Icons.public, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Secret Key
              TextField(
                controller: skCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isArabic ? 'المفتاح السري (Secret Key)' : 'Secret Key (sk_...)',
                  hintText: 'sk_live_... / sk_test_...',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final pk = pkCtrl.text.trim();
                          final sk = skCtrl.text.trim();

                          if (pk.isEmpty || sk.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red[800],
                                content: Text(
                                  isArabic ? 'يرجى إدخال المفتاح العام والمفتاح السري' : 'Please provide both publishable and secret keys',
                                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(modalContext);
                          setModalState(() => isSaving = true);

                          try {
                            final res = await ApiClient.instance.post('/stripe/update-keys', data: {
                              'publishable_key': pk,
                              'secret_key': sk,
                            });

                            if (res.data['success'] == true) {
                              nav.pop();
                              await _loadStripeConfig();

                              messenger.showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green[800],
                                  content: Text(
                                    isArabic ? 'تم حفظ مفاتيح Stripe وتفعيل البوابة بنجاح!' : 'Stripe keys updated and gateway activated!',
                                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red[800],
                                content: Text(
                                  isArabic ? 'حدث خطأ أثناء حفظ المفاتيح' : 'Error updating keys',
                                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isArabic ? 'حفظ المفاتيح في النظام' : 'Save Stripe Keys',
                          style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
      );
      return;
    }

    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final cartItems = ref.read(cartProvider);
    final session = ref.read(sessionProvider);

    if (cartItems.isEmpty) {
      _showErrorSnackBar(isArabic ? 'السلة فارغة' : 'Your cart is empty');
      return;
    }

    // A. Online Payment via Stripe Hosted Checkout (Apple Pay, Google Pay, Mada, Cards)
    if (_selectedType == PaymentType.stripe) {
      setState(() {
        _isProcessing = true;
        _processingMessage = isArabic
            ? 'جاري تجهيز بوابة Stripe الآمنة...'
            : 'Connecting to Stripe Checkout...';
      });

      try {
        final itemsPayload = cartItems.map((item) => {
          'product_id': item.productId,
          'quantity': item.quantity,
          'special_instructions': item.specialInstructions ?? '',
          'options': item.selectedOptions.map((o) => o.id).toList(),
        }).toList();

        final payload = {
          'session_id': session.sessionId ?? 'guest-sess-${DateTime.now().millisecondsSinceEpoch}',
          'order_type': session.orderType,
          'items': itemsPayload,
          'table_id': session.tableId,
          'branch_id': session.branchId ?? 1,
          'payment_method': 'stripe',
        };

        if (session.orderType == 'car' && session.vehicleDetails != null) {
          payload['vehicle_details'] = session.vehicleDetails!;
        }

        final res = await ApiClient.instance.post('/stripe/create-checkout-session', data: payload);

        if (res.data != null && res.data['success'] == true) {
          final checkoutUrl = res.data['checkout_url'] as String;
          final orderNumber = res.data['order_number'] as String;

          // Open Stripe Checkout in external browser / app
          final uri = Uri.parse(checkoutUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          if (mounted) {
            setState(() => _isProcessing = false);
            // DO NOT clear cart and DO NOT start order yet!
            _showAwaitingStripePaymentDialog(orderNumber);
          }
          return;
        } else {
          throw Exception(res.data?['message'] ?? (isArabic ? 'فشل إنشاء جلسة الدفع في Stripe' : 'Failed to create Stripe session'));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          String msg = isArabic ? 'تعذر الاتصال ببوابة Stripe' : 'Could not connect to Stripe';
          if (e is DioException) {
            final serverMsg = e.response?.data?['message'];
            if (serverMsg != null && serverMsg.toString().isNotEmpty) {
              msg = serverMsg.toString();
            } else if (e.message != null && e.message!.isNotEmpty) {
              msg = e.message!;
            }
          } else {
            msg = e.toString().replaceFirst('Exception: ', '');
          }
          _showErrorSnackBar(msg);
        }
        return;
      }
    }

    // B. Offline Payment (Wallet or Cash on delivery)
    setState(() {
      _isProcessing = true;
      _processingMessage = isArabic ? 'جاري تأكيد الطلب...' : 'Submitting order...';
    });

    try {
      final itemsPayload = cartItems.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'special_instructions': item.specialInstructions ?? '',
        'options': item.selectedOptions.map((o) => o.id).toList(),
      }).toList();

      final payload = {
        'session_id': session.sessionId ?? 'guest-sess-${DateTime.now().millisecondsSinceEpoch}',
        'order_type': session.orderType,
        'items': itemsPayload,
        'payment_method': _selectedType == PaymentType.n8Wallet ? 'wallet' : 'cash',
        'table_id': session.tableId,
        'branch_id': session.branchId ?? 1,
      };

      if (session.orderType == 'car' && session.vehicleDetails != null) {
        payload['vehicle_details'] = session.vehicleDetails!;
      }

      final response = await ApiClient.instance.post('/checkout', data: payload);

      if (response.data['success']) {
        final orderNumber = response.data['order_number'] ?? '#NE1278';

        if (mounted) {
          ref.read(cartProvider.notifier).clearCart();
          setState(() => _isProcessing = false);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(
                orderNumber: orderNumber,
                initialMinutes: 10,
                initialSeconds: 0,
              ),
            ),
            (route) => route.isFirst,
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        String msg = isArabic ? 'تعذر إتمام عملية الطلب' : 'Could not place order';
        if (e is DioException) {
          final serverMsg = e.response?.data?['message'];
          if (serverMsg != null && serverMsg.toString().isNotEmpty) {
            msg = serverMsg.toString();
          } else if (e.message != null && e.message!.isNotEmpty) {
            msg = e.message!;
          }
        } else {
          msg = e.toString().replaceFirst('Exception: ', '');
        }
        _showErrorSnackBar(msg);
      }
    }
  }

  void _showAwaitingStripePaymentDialog(String orderNumber) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    Timer? pollTimer;
    bool isChecking = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Start automatic polling every 3 seconds
            pollTimer ??= Timer.periodic(const Duration(seconds: 3), (t) async {
              try {
                final checkRes = await ApiClient.instance.post('/stripe/verify-payment', data: {
                  'order_number': orderNumber,
                });
                  if (checkRes.data != null && checkRes.data['is_paid'] == true) {
                    t.cancel();
                    if (mounted) {
                      try {
                        Navigator.of(modalCtx, rootNavigator: true).pop();
                      } catch (_) {}
                      ref.read(cartProvider.notifier).clearCart();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(
                            orderNumber: orderNumber,
                            initialMinutes: 10,
                            initialSeconds: 0,
                          ),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  }
              } catch (_) {}
            });

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF635BFF).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF635BFF),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'بانتظار إتمام الدفع في Stripe' : 'Awaiting Stripe Payment',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'يرجى إتمام عملية الدفع في صفحة Stripe المفتوحة. لن يبدأ تحضير طلبك إلا بعد نجاح الدفع.'
                        : 'Please complete your payment on the opened Stripe page. Your order will start preparing once payment is confirmed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Text(
                      '${isArabic ? "رقم الطلب" : "Order"}: $orderNumber',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            pollTimer?.cancel();
                            Navigator.pop(modalCtx);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            isArabic ? 'إلغاء والعودة' : 'Cancel & Back',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isChecking
                              ? null
                              : () async {
                                  setModalState(() => isChecking = true);
                                  try {
                                    final res = await ApiClient.instance.post('/stripe/verify-payment', data: {
                                      'order_number': orderNumber,
                                    });
                                    if (res.data != null && res.data['is_paid'] == true) {
                                      pollTimer?.cancel();
                                      if (mounted) {
                                        try {
                                          Navigator.of(modalCtx, rootNavigator: true).pop();
                                        } catch (_) {}
                                        ref.read(cartProvider.notifier).clearCart();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OrderTrackingScreen(
                                              orderNumber: orderNumber,
                                              initialMinutes: 10,
                                              initialSeconds: 0,
                                            ),
                                          ),
                                          (route) => route.isFirst,
                                        );
                                      }
                                      return;
                                    } else {
                                      setModalState(() => isChecking = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isArabic
                                                ? 'لم يتم تأكيد الدفع بعد. يرجى إكمال الدفع في صفحة Stripe أولاً.'
                                                : 'Payment not yet confirmed. Please complete it first.',
                                            style: GoogleFonts.tajawal(),
                                          ),
                                          backgroundColor: Colors.orange[800],
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setModalState(() => isChecking = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF635BFF),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  isArabic ? 'تحقق من الدفع' : 'Check Payment',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      pollTimer?.cancel();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final cartItems = ref.watch(cartProvider);

    final subtotal = widget.totalAmount / 1.05;
    final vat = widget.totalAmount - subtotal;

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
            isArabic ? 'الدفع الآمن' : 'Secure Checkout',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Order Summary Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isArabic ? 'ملخص الطلب (${cartItems.length} أصناف)' : 'Order Summary (${cartItems.length} items)',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlack,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'N°8',
                                    style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.lightBorder, height: 1),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              isArabic ? 'المجموع الفرعي' : 'Subtotal',
                              '${subtotal.toStringAsFixed(2)} AED',
                            ),
                            const SizedBox(height: 6),
                            _buildSummaryRow(
                              isArabic ? 'ضريبة القيمة المضافة (5% VAT)' : 'VAT (5%)',
                              '${vat.toStringAsFixed(2)} AED',
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.lightBorder, height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isArabic ? 'الإجمالي للدفع' : 'Total to Pay',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                Text(
                                  '${widget.totalAmount.toInt()} AED',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 2. Payment Method Selector Header
                      Text(
                        isArabic ? 'اختر طريقة الدفع' : 'Select Payment Method',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1. Stripe Hosted Checkout (Apple Pay, Google Pay, Mada, Cards)
                      _buildMethodTile(
                        type: PaymentType.stripe,
                        title: isArabic ? 'الدفع الإلكتروني (Stripe)' : 'Online Payment (Stripe)',
                        subtitle: isArabic
                            ? 'Apple Pay، Google Pay، مدى، فيزا، ماستركارد'
                            : 'Apple Pay, Google Pay, Mada, Visa, Mastercard',
                        badge: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF635BFF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isStripeConfigured ? (_isStripeLive ? 'LIVE' : 'TEST') : 'READY',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF635BFF),
                            ),
                          ),
                        ),
                        iconWidget: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF635BFF), Color(0xFF1F1D36)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.payment_rounded, color: Colors.white, size: 22),
                        ),
                      ),

                      // Stripe Hosted Checkout Info Banner
                      if (_selectedType == PaymentType.stripe) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF635BFF).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF635BFF).withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF635BFF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.security, color: Color(0xFF635BFF), size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isArabic ? 'بوابة Stripe الرسمية والمشفرة' : 'Official Encrypted Stripe Gateway',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF635BFF),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _showStripeKeySettingsDialog,
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF635BFF).withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.key, size: 12, color: Color(0xFF635BFF)),
                                          const SizedBox(width: 4),
                                          Text(
                                            isArabic ? 'المفاتيح' : 'Keys',
                                            style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF635BFF)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isArabic
                                    ? 'سيتم نقلك فوراً وبأمان إلى صفحة Stripe لإتمام الدفع بـ Apple Pay أو Google Pay أو البطاقات البنكية (مدى، فيزا، ماستركارد). ولن يبدأ تحضير الطلب إلا بعد نجاح الدفع.'
                                    : 'You will be redirected securely to Stripe to pay via Apple Pay, Google Pay, or cards. Your order will start preparing only after payment is confirmed.',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildBrandBadge('Pay', true, Colors.black),
                                  const SizedBox(width: 6),
                                  _buildBrandBadge('GPay', true, const Color(0xFF4285F4)),
                                  const SizedBox(width: 6),
                                  _buildBrandBadge('MADA', true, const Color(0xFF007A3D)),
                                  const SizedBox(width: 6),
                                  _buildBrandBadge('VISA', true, const Color(0xFF1A1F71)),
                                  const SizedBox(width: 6),
                                  _buildBrandBadge('MC', true, const Color(0xFFEB001B)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // N8 Wallet
                      _buildMethodTile(
                        type: PaymentType.n8Wallet,
                        title: isArabic ? 'محفظة NUMBER EIGHT' : 'N8 Wallet',
                        subtitle: isArabic ? 'الرصيد المتاح: 120 AED' : 'Available Balance: 120 AED',
                        iconWidget: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.goldAccent, size: 22),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Cash on Delivery
                      _buildMethodTile(
                        type: PaymentType.cashOnDelivery,
                        title: isArabic ? 'الدفع في الكافيه / عند الاستلام' : 'Pay at Counter / on Arrival',
                        subtitle: isArabic ? 'نقداً أو عبر بطاقة الدفع عند الاستلام' : 'Cash or Card upon pickup',
                        iconWidget: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.storefront_outlined, color: Colors.green, size: 22),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Checkout Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.lightBorder, width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _processingMessage,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedType == PaymentType.stripe
                                      ? Icons.lock_outline
                                      : _selectedType == PaymentType.n8Wallet
                                          ? Icons.account_balance_wallet_outlined
                                          : Icons.storefront_outlined,
                                  color: AppColors.goldAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedType == PaymentType.stripe
                                      ? (isArabic
                                          ? 'المتابعة والدفع عبر Stripe (${widget.totalAmount.toInt()} AED)'
                                          : 'Continue & Pay with Stripe (${widget.totalAmount.toInt()} AED)')
                                      : _selectedType == PaymentType.n8Wallet
                                          ? (isArabic
                                              ? 'الدفع عبر المحفظة (${widget.totalAmount.toInt()} AED)'
                                              : 'Pay with N8 Wallet (${widget.totalAmount.toInt()} AED)')
                                          : (isArabic
                                              ? 'تأكيد الطلب والدفع عند الاستلام'
                                              : 'Confirm & Pay at Counter'),
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'مدعوم بواسطة بوابة Stripe الآمنة وبتشفير 256-Bit SSL' : 'Powered by Stripe 256-Bit SSL Encrypted Gateway',
                          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.secondaryText),
                        ),
                      ],
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

  Widget _buildBrandBadge(String label, bool isSelected, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade400,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.secondaryText),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
        ),
      ],
    );
  }

  Widget _buildMethodTile({
    required PaymentType type,
    required String title,
    required String subtitle,
    required Widget iconWidget,
    Widget? badge,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlack : AppColors.lightBorder,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        badge,
                      ],
                    ],
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
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlack : AppColors.secondaryText,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryBlack : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
