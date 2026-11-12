import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../providers/locale_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import 'menu_screen.dart';
import 'orders_history_screen.dart';
import 'offers_screen.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';

class TableQrScreen extends ConsumerStatefulWidget {
  const TableQrScreen({super.key});

  @override
  ConsumerState<TableQrScreen> createState() => _TableQrScreenState();
}

class _TableQrScreenState extends ConsumerState<TableQrScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _tableInputController = TextEditingController();
  bool _isLoading = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _tableInputController.dispose();
    super.dispose();
  }

  void _validateAndProceed(String tableNum) async {
    if (tableNum.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.post('/scan-qr', data: {
        'table_number': tableNum.trim(),
      });

      if (response.data['success']) {
        final data = response.data;
        ref.read(sessionProvider.notifier).startTableSession(
          tableNumber: data['table_number'].toString(),
          tableId: data['table_id'],
          sessionId: data['session_id'],
          branchName: data['branch_name'] ?? 'Al Khabisi Branch',
          branchId: data['branch_id'] ?? 1,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(orderType: 'table', tableNumber: data['table_number'].toString()),
            ),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to validate table');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isArabic = ref.read(localeProvider).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Text(
              isArabic 
                  ? 'رقم طاولة غير صحيح أو تعذر الاتصال بالخادم' 
                  : 'Invalid table number or server error',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    }
  }

  void _validateAndProceedWithToken(String token) async {
    if (token.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.post('/scan-qr', data: {
        'qr_token': token.trim(),
      });

      if (response.data['success']) {
        final data = response.data;
        ref.read(sessionProvider.notifier).startTableSession(
          tableNumber: data['table_number'].toString(),
          tableId: data['table_id'],
          sessionId: data['session_id'],
          branchName: data['branch_name'] ?? 'Al Khabisi Branch',
          branchId: data['branch_id'] ?? 1,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(orderType: 'table', tableNumber: data['table_number'].toString()),
            ),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to validate table');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isArabic = ref.read(localeProvider).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Text(
              isArabic 
                  ? 'كود QR غير صالح أو تعذر الاتصال بالخادم' 
                  : 'Invalid QR Code or server error',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
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
            isArabic ? 'اطلب من داخل الكوفي' : 'Order Inside Café',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                  child: Column(
                    children: [
                      // White Card for Scanner & Input
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isArabic ? 'امسح QR Code الموجود على طاولتك' : 'Scan the QR Code on your table',
                              style: GoogleFonts.tajawal(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 18),

                            // Prominent Action Button: Scan Table QR with Camera
                            ElevatedButton.icon(
                              onPressed: () async {
                                final resultToken = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                                );
                                if (resultToken != null && resultToken.isNotEmpty) {
                                  _validateAndProceedWithToken(resultToken);
                                }
                              },
                              icon: const Icon(Icons.qr_code_scanner_rounded, size: 22, color: Colors.white),
                              label: Text(
                                isArabic ? '📷 فتح الكاميرا لمسح كود الطاولة' : '📷 Open Camera to Scan QR',
                                style: GoogleFonts.tajawal(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlack,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // QR Scanner Box with animated scan line
                            GestureDetector(
                              onTap: () async {
                                final resultToken = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                                );
                                if (resultToken != null && resultToken.isNotEmpty) {
                                  _validateAndProceedWithToken(resultToken);
                                }
                              },
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF9F6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Vector QR code mock
                                    Image.network(
                                      'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=N8-TABLE-08&color=101010&bgcolor=FAF9F6',
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.qr_code_2,
                                        size: 130,
                                        color: AppColors.primaryBlack,
                                      ),
                                    ),

                                    // Animated scanning line
                                    AnimatedBuilder(
                                      animation: _animController,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: 10 + (_animController.value * 150),
                                          left: 10,
                                          right: 10,
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              color: AppColors.successGreen,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.successGreen.withValues(alpha: 0.6),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider text
                            Text(
                              isArabic ? 'أو أدخل رقم أو اسم الطاولة يدوياً' : 'Or enter table number manually',
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Manual input box matching reference
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.lightBorder, width: 1.2),
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _tableInputController,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlack,
                                ),
                                decoration: InputDecoration(
                                  hintText: isArabic ? 'مثال: 08 أو T-01 أو VIP' : 'e.g. 08 or T-01',
                                  hintStyle: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    color: AppColors.secondaryText.withValues(alpha: 0.6),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            ElevatedButton(
                              onPressed: _isLoading ? null : () => _validateAndProceed(_tableInputController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlack,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      isArabic ? 'تأكيد الطاولة والمتابعة للمنيو' : 'Confirm Table & Open Menu',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 15,
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

              N8BottomNav(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pop(context);
                  } else if (index == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()));
                  } else if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersScreen()));
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
}
