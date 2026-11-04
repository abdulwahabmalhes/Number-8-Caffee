import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import 'menu_screen.dart';
import 'orders_history_screen.dart';
import 'loyalty_tier_screen.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';

class CarServiceScreen extends ConsumerStatefulWidget {
  const CarServiceScreen({super.key});

  @override
  ConsumerState<CarServiceScreen> createState() => _CarServiceScreenState();
}

class _CarServiceScreenState extends ConsumerState<CarServiceScreen> {
  final TextEditingController _plateNumberController = TextEditingController(text: '12345 أ ب');
  String _selectedModel = 'مرسيدس G63';
  String _selectedColor = 'أسود';
  int _currentNavIndex = 0;

  final List<String> _carModelsAr = [
    'مرسيدس G63',
    'نيسان باترول',
    'تويوتا لاندكروزر',
    'ديفندر',
    'بورشه كايين',
    'لكزس LX570',
    'بي إم دبليو X6',
    'أخرى',
  ];

  final List<String> _carColorsAr = [
    'أسود',
    'أبيض',
    'رمادي',
    'فضي',
    'كحلي',
    'بني',
  ];

  void _proceedToMenu() {
    final vehicleData = {
      'plate_number': _plateNumberController.text.trim(),
      'vehicle_model': _selectedModel,
      'vehicle_color': _selectedColor,
    };

    ref.read(sessionProvider.notifier).startCarService(vehicleData);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MenuScreen(orderType: 'car'),
      ),
    );
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    super.dispose();
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
            isArabic ? 'الطلب من السيارة' : 'Order from Car',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Car Hero Graphic (Mercedes G-Class styling)
                      Container(
                        height: 140,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1520050206274-a1ae44613e6d?q=80&w=600&auto=format&fit=crop',
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.lightBorder),
                              ),
                              child: const Center(
                                child: Icon(Icons.directions_car_filled, size: 64, color: AppColors.primaryBlack),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        isArabic ? 'الطلب قبل وصولك' : 'Order before you arrive',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'وسنجهز طلبك لتستلمه بدون انتظار'
                            : 'We will prepare your order for contactless delivery',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Form: Plate Number
                      _buildFieldLabel(isArabic ? 'رقم اللوحة' : 'Plate Number'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Container(
                                width: 28,
                                height: 18,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.lightBorder),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text('🇦🇪', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _plateNumberController,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Form: Car Model
                      _buildFieldLabel(isArabic ? 'نوع السيارة' : 'Vehicle Model'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedModel,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlack,
                            ),
                            items: _carModelsAr.map((model) {
                              return DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedModel = val);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Form: Car Color
                      _buildFieldLabel(isArabic ? 'لون السيارة' : 'Vehicle Color'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedColor,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlack,
                            ),
                            items: _carColorsAr.map((color) {
                              return DropdownMenuItem<String>(
                                value: color,
                                child: Text(color),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedColor = val);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit Button "التالي"
                      ElevatedButton(
                        onPressed: _proceedToMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isArabic ? 'التالي' : 'Next',
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

              N8BottomNav(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pop(context);
                  } else if (index == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()));
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

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
