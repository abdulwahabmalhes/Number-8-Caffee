import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/session_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import '../widgets/n8_logo.dart';
import '../widgets/n8_popup.dart';
import '../core/api_client.dart';
import 'loyalty_tier_screen.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderNumber;
  final int initialMinutes;
  final int initialSeconds;

  const OrderTrackingScreen({
    super.key,
    this.orderNumber = '#1278',
    this.initialMinutes = 8,
    this.initialSeconds = 45,
  });

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  late int _totalSeconds;
  Timer? _timer;
  int _currentStep = 1; // 0: تم الاستلام, 1: قيد التجهيز, 2: جاهز للاستلام, 3: تم التسليم
  bool _hasArrived = false;
  int _currentNavIndex = 1;

  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _totalSeconds = (widget.initialMinutes * 60) + widget.initialSeconds;
    _startTimer();
    _startStatusPolling();
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final res = await ApiClient.instance.get('/orders/${Uri.encodeComponent(widget.orderNumber)}/status');
        if (!mounted) return;
        if (res.data['success']) {
          final status = res.data['status'];
          if (status == 'new' || status == 'accepted') {
            setState(() => _currentStep = 1);
          } else if (status == 'preparing') {
            setState(() => _currentStep = 1);
          } else if (status == 'ready') {
            setState(() => _currentStep = 2);
          } else if (status == 'delivered') {
            setState(() {
              _currentStep = 3;
              _timer?.cancel();
            });
            _statusTimer?.cancel();
            _showDeliveryPopup();
          }
        }
      } catch (e) {
        debugPrint('Error polling status: $e');
      }
    });
  }

  void _showDeliveryPopup() {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    N8Popup.showSuccess(
      context: context,
      title: isArabic ? 'بالعافية!' : 'Enjoy!',
      message: isArabic
          ? 'تم تسليم طلبك بنجاح. شكراً لاختيارك نمبر إيت ☕'
          : 'Your order has been delivered successfully. Thank you for choosing Number Eight ☕',
      primaryBtnText: isArabic ? 'عرض الفاتورة' : 'View Receipt',
      onPrimaryAction: () {
        Navigator.pop(context); // close popup
        _showOrderDetailsSheet(context, isArabic); // open receipt
      }
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() => _totalSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  String get _timerFormatted {
    final mins = (_totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _notifyArrival() {
    setState(() => _hasArrived = true);
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    N8Popup.showSuccess(
      context: context,
      title: isArabic ? 'تم تأكيد وصولك بنجاح' : 'Arrival Confirmed',
      message: isArabic
          ? 'تم إرسال إشعار فوري لطاقم نمبر إيت وسيتم تسليم طلبك للسيارة فوراً 🚗'
          : 'Number Eight staff has been notified and your order is on its way to your car 🚗',
      primaryBtnText: isArabic ? 'حسناً' : 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final session = ref.watch(sessionProvider);
    final isCarOrder = session.orderType == 'car';

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
          title: Column(
            children: [
              Text(
                isArabic ? 'طلبك قيد التجهيز' : 'Order in Progress',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlack,
                ),
              ),
              Text(
                widget.orderNumber,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // Digital Cup Sticker Container
                      Container(
                        width: 170,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.orderNumber,
                                  style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '1 of 1',
                                  style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const N8Logo(size: 34, showText: false),
                            const SizedBox(height: 6),
                            Text(
                              ref.watch(authProvider).user?['name'] ?? (isArabic ? 'عميلنا المميز' : 'Valued Customer'),
                              style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryBlack),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'حلو إنك هنا 🤍',
                              style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldAccent),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Specialty Coffee • Handcrafted',
                                style: GoogleFonts.dmSans(fontSize: 8.5, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status Title
                      Text(
                        isArabic ? 'جاري تحضير طلبك' : 'Preparing Your Order',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        isArabic ? 'جاهز خلال' : 'Ready in approximately',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Big Countdown Timer (e.g. 08:45 دقيقة)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _timerFormatted,
                            style: GoogleFonts.dmSans(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlack,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'دقيقة' : 'min',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 4-Stage Stepper Timeline matching reference
                      _buildTimelineStepper(isArabic),

                      const SizedBox(height: 32),

                      // If Car Order -> "لقد وصلت / I Have Arrived" Action Button
                      if (isCarOrder) ...[
                        ElevatedButton.icon(
                          onPressed: _hasArrived ? null : _notifyArrival,
                          icon: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20),
                          label: Text(
                            _hasArrived
                                ? (isArabic ? 'تم تأكيد وصولك ✓' : 'Arrival Confirmed ✓')
                                : (isArabic ? 'لقد وصلت / I Have Arrived' : 'I Have Arrived'),
                            style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasArrived ? AppColors.successGreen : AppColors.primaryBlack,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size(double.infinity, 54),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // "تفاصيل الطلب" Solid Black Button
                      OutlinedButton(
                        onPressed: () {
                          _showOrderDetailsSheet(context, isArabic);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: AppColors.cardBackground,
                        ),
                        child: Text(
                          isArabic ? 'تفاصيل الطلب' : 'Order Details',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              N8BottomNav(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() => _currentNavIndex = index);
                  if (index == 0) {
                    Navigator.pop(context);
                  } else if (index == 1) {
                    // Current tracking
                  } else if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyTierScreen()));
                  } else if (index == 3) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyPunchScreen()));
                  } else if (index == 4) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStepper(bool isArabic) {
    final stages = [
      {'ar': 'تم الاستلام', 'en': 'Received'},
      {'ar': 'قيد التحضير', 'en': 'Preparing'},
      {'ar': 'جاهز للاستلام', 'en': 'Ready'},
      {'ar': 'تم التسليم', 'en': 'Delivered'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (index) {
              final isPassed = index <= _currentStep;
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed ? AppColors.primaryBlack : AppColors.background,
                        border: Border.all(
                          color: isCurrent ? AppColors.primaryBlack : AppColors.lightBorder,
                          width: isCurrent ? 3 : 1.5,
                        ),
                      ),
                    ),
                    if (index < stages.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < _currentStep ? AppColors.primaryBlack : AppColors.lightBorder,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (index) {
              final stage = stages[index];
              final isCurrent = index == _currentStep;
              return Expanded(
                child: Text(
                  isArabic ? stage['ar']! : stage['en']!,
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? AppColors.primaryBlack : AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isArabic ? 'عناصر الطلب #1278' : 'Order Items #1278',
                style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.lightBorder),
              const SizedBox(height: 8),
              _buildItemRow('Spanish Latte (L)', '1x', '24 AED'),
              const SizedBox(height: 8),
              _buildItemRow('Iced Latte (M)', '1x', '22 AED'),
              const SizedBox(height: 8),
              _buildItemRow('Blueberry Muffin', '1x', '16 AED'),
              const SizedBox(height: 8),
              _buildItemRow(isArabic ? 'رسوم الخدمة' : 'Service Fee', '', '2 AED'),
              const SizedBox(height: 12),
              const Divider(color: AppColors.lightBorder),
              const SizedBox(height: 8),
              _buildItemRow(isArabic ? 'الإجمالي' : 'Total', '', '64 AED', isBold: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isArabic ? 'إغلاق' : 'Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemRow(String title, String qty, String price, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (qty.isNotEmpty) ...[
              Text(qty, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
        Text(
          price,
          style: GoogleFonts.dmSans(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }
}
