import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../core/api_client.dart';
import '../providers/auth_provider.dart';
import 'offers_screen.dart';

class LoyaltyPunchScreen extends ConsumerStatefulWidget {
  const LoyaltyPunchScreen({super.key});

  @override
  ConsumerState<LoyaltyPunchScreen> createState() => _LoyaltyPunchScreenState();
}

class _LoyaltyPunchScreenState extends ConsumerState<LoyaltyPunchScreen> {
  int _completedCups = 0;
  final int _targetCups = 8;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchCups());
  }

  Future<void> _fetchCups() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await ApiClient.instance.get('/orders');
      if (res.data['success'] && mounted) {
        final orders = res.data['orders'] as List<dynamic>;
        int totalCups = 0;
        for (var o in orders) {
          if (o['payment_status'] == 'paid') {
            final items = o['items'] as List<dynamic>? ?? [];
            for (var item in items) {
              totalCups += (item['quantity'] as num?)?.toInt() ?? 1;
            }
          }
        }
        setState(() {
          _completedCups = totalCups % _targetCups;
          if (_completedCups == 0 && totalCups > 0) {
            _completedCups = _targetCups;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
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
            isArabic ? 'التقدم نحو المكافأة' : 'Punch Card Progress',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        isArabic
                            ? 'اشتري 8 أكواب واحصل على\nالكوب التاسع مجاناً'
                            : 'Buy 8 cups & get your\n9th cup on us',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 36),

                      // Circular Arc Cup Tracker matching reference Screen 10
                      Center(
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Arc progress paint
                              CustomPaint(
                                size: const Size(220, 220),
                                painter: _PunchArcPainter(
                                  completedCount: _completedCups,
                                  totalCount: _targetCups,
                                ),
                              ),

                              // Cups positioned around the perimeter
                              ...List.generate(_targetCups, (index) {
                                final angle = (index * (2 * math.pi / _targetCups)) - (math.pi / 2);
                                const radius = 105.0;
                                final x = radius * math.cos(angle);
                                final y = radius * math.sin(angle);
                                final isFilled = index < _completedCups;

                                return Transform.translate(
                                  offset: Offset(x, y),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled ? AppColors.primaryBlack : AppColors.cardBackground,
                                      border: Border.all(
                                        color: isFilled ? AppColors.primaryBlack : AppColors.lightBorder,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        if (isFilled)
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 4,
                                          ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.local_cafe,
                                        size: 16,
                                        color: isFilled ? const Color(0xFFD4AF37) : AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // Center Info
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$_completedCups/$_targetCups',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                  Text(
                                    isArabic ? 'أكواب' : 'Cups',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Solid Black CTA: "عرض المكافآت"
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OffersScreen()),
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
                          isArabic ? 'عرض المكافآت' : 'View Rewards & Offers',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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

class _PunchArcPainter extends CustomPainter {
  final int completedCount;
  final int totalCount;

  _PunchArcPainter({required this.completedCount, required this.totalCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 80.0;

    final bgPaint = Paint()
      ..color = AppColors.lightBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final progressPaint = Paint()
      ..color = AppColors.primaryBlack
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (completedCount / totalCount) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
