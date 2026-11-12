import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/session_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import 'menu_screen.dart';
import 'orders_history_screen.dart';
import 'offers_screen.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';

class CarServiceScreen extends ConsumerStatefulWidget {
  const CarServiceScreen({super.key});

  @override
  ConsumerState<CarServiceScreen> createState() => _CarServiceScreenState();
}

class _CarServiceScreenState extends ConsumerState<CarServiceScreen> {
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _customModelController = TextEditingController();

  String _selectedEmirate = 'أبوظبي';
  String _selectedBrand = 'Jetour جيتور';
  String _selectedModel = 'Jetour T2';
  bool _isCustomModel = false;
  bool _saveToFavorites = true;

  // Selected Color
  String _selectedColorNameAr = 'أسود';
  String _selectedColorNameEn = 'Black';
  Color _selectedColorVal = const Color(0xFF111111);

  final List<Map<String, String>> _emirates = [
    {'ar': 'أبوظبي', 'en': 'Abu Dhabi'},
    {'ar': 'دبي', 'en': 'Dubai'},
    {'ar': 'الشارقة', 'en': 'Sharjah'},
    {'ar': 'عجمان', 'en': 'Ajman'},
    {'ar': 'أم القيوين', 'en': 'Umm Al Quwain'},
    {'ar': 'رأس الخيمة', 'en': 'Ras Al Khaimah'},
    {'ar': 'الفجيرة', 'en': 'Fujairah'},
  ];

  final Map<String, List<String>> _brandModels = {
    // Chinese Brands in UAE (High demand)
    'Jetour جيتور': ['Jetour T2', 'Jetour Dashing', 'Jetour X70 Plus', 'Jetour X90 Plus'],
    'Geely جيلي': ['Geely Monjaro', 'Geely Tugella', 'Geely Coolray', 'Geely Okavango', 'Geely Emgrand'],
    'Haval هافال': ['Tank 300', 'Tank 500', 'Haval Dargo', 'Haval H6', 'Haval Jolion'],
    'Changan شانجان': ['Changan CS95', 'Changan CS85', 'Changan UNI-K', 'Changan UNI-T', 'Changan UNI-V'],
    'BYD بي واي دي': ['BYD Seal', 'BYD Atto 3', 'BYD Han', 'BYD Tang', 'BYD Song Plus'],
    'Chery شيري': ['Tiggo 8 Pro Max', 'Tiggo 7 Pro', 'Arrizo 8'],
    'Hongqi هونشي': ['Hongqi H9', 'Hongqi HS5', 'Hongqi E-HS9', 'Hongqi H5'],
    'MG إم جي': ['MG RX8', 'MG GT', 'MG Whale', 'MG ONE', 'MG 4 Electric'],
    'GAC جي أيه سي': ['GAC Empow', 'GAC GS8', 'GAC Emkoo'],
    'Jaecoo جيكو': ['Jaecoo 7', 'Jaecoo 8'],
    'Exeed إكسيد': ['Exeed RX', 'Exeed VX', 'Exeed TXL'],
    // Popular & Luxury in UAE
    'Toyota تويوتا': ['Land Cruiser LC300', 'Prado', 'Camry', 'RAV4', 'Hilux', 'Crown'],
    'Nissan نيسان': ['Patrol V8', 'Patrol Nismo', 'Patrol Super Safari', 'Altima', 'X-Trail'],
    'Lexus لكزس': ['Lexus LX600', 'Lexus LX570', 'Lexus RX', 'Lexus ES'],
    'Mercedes-Benz مرسيدس': ['G-Class G63 AMG', 'S-Class', 'E-Class', 'C-Class', 'GLE Coupe', 'GLS'],
    'Land Rover لاندروفر': ['Defender 110', 'Defender 90', 'Defender 130', 'Range Rover Vogue', 'Range Rover Sport'],
    'BMW بي إم دبليو': ['BMW 7 Series', 'BMW X7', 'BMW X5', 'BMW X6', 'BMW 5 Series'],
    'Porsche بورشه': ['Porsche Cayenne', 'Porsche Macan', 'Porsche Panamera', 'Porsche 911'],
    'Audi أودي': ['Audi Q8', 'Audi Q7', 'Audi A8', 'Audi RSQ8'],
    'GMC جي إم سي': ['Yukon Denali', 'Sierra', 'Terrain'],
    'Cadillac كاديلاك': ['Escalade', 'CT5', 'XT6'],
    'Hyundai هيونداي': ['Palisade', 'Santa Fe', 'Sonata', 'Tucson'],
    'Kia كيا': ['Telluride', 'Sportage', 'K5', 'Sorento'],
    'Ford فورد': ['F-150 Raptor', 'Expedition', 'Explorer', 'Mustang'],
    'أخرى (إدخال يدوي) / Other': ['أخرى (كتابة يدوي)'],
  };

  final List<Map<String, dynamic>> _carColors = [
    {'ar': 'أسود', 'en': 'Black', 'color': const Color(0xFF111111)},
    {'ar': 'أبيض', 'en': 'White', 'color': const Color(0xFFFFFFFF)},
    {'ar': 'لؤلؤي', 'en': 'Pearl', 'color': const Color(0xFFF6F4EB)},
    {'ar': 'رمادي', 'en': 'Grey', 'color': const Color(0xFF757575)},
    {'ar': 'فضي', 'en': 'Silver', 'color': const Color(0xFFD1D5DB)},
    {'ar': 'كحلي', 'en': 'Navy Blue', 'color': const Color(0xFF1E3A8A)},
    {'ar': 'أزرق', 'en': 'Blue', 'color': const Color(0xFF2563EB)},
    {'ar': 'بني', 'en': 'Brown', 'color': const Color(0xFF5C3A21)},
    {'ar': 'ذهبي', 'en': 'Gold', 'color': const Color(0xFFD4AF37)},
    {'ar': 'زيتي', 'en': 'Olive Green', 'color': const Color(0xFF3F4E3E)},
    {'ar': 'أحمر', 'en': 'Red', 'color': const Color(0xFFDC2626)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedModel = _brandModels[_selectedBrand]!.first;
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _customModelController.dispose();
    super.dispose();
  }

  void _selectSavedVehicle(VehicleItem v) {
    setState(() {
      _selectedEmirate = v.plateEmirate;
      _plateNumberController.text = v.plateNumber;
      _isCustomModel = true;
      _customModelController.text = v.model;
      _selectedColorNameAr = v.color;
      _selectedColorNameEn = v.color;
    });
  }

  void _proceedToMenu() {
    final plateNum = _plateNumberController.text.trim();
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    if (plateNum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'يرجى إدخال رقم اللوحة للتعرف على سيارتك' : 'Please enter your plate number',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final finalModel = _isCustomModel && _customModelController.text.trim().isNotEmpty
        ? _customModelController.text.trim()
        : _selectedModel;

    final finalColor = isArabic ? _selectedColorNameAr : _selectedColorNameEn;

    final vehicleData = {
      'plate_number': plateNum,
      'plate_emirate': _selectedEmirate,
      'vehicle_model': finalModel,
      'vehicle_color': finalColor,
    };

    if (_saveToFavorites) {
      ref.read(userDataProvider.notifier).addVehicle(
            VehicleItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              plateNumber: plateNum,
              plateEmirate: _selectedEmirate,
              model: finalModel,
              color: finalColor,
            ),
          );
    }

    ref.read(sessionProvider.notifier).startCarService(vehicleData);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MenuScreen(orderType: 'car'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final savedVehicles = ref.watch(userDataProvider).vehicles;

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
            isArabic ? 'الطلب من السيارة' : 'Car Pickup Service',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Car Hero Graphic using the official luxury transparent image
                      Container(
                        height: 150,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/car_pickup.png',
                          height: 145,
                          fit: BoxFit.contain,
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

                      const SizedBox(height: 12),

                      Text(
                        isArabic ? 'استلم قهوتك وأنت بسيارتك' : 'Specialty Coffee Delivered to Your Car',
                        style: GoogleFonts.tajawal(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isArabic
                            ? 'أدخل بيانات سيارتك لنقوم بتوصيل الطلب إليك فور وصولك'
                            : 'Enter your vehicle details for seamless curbside delivery',
                        style: GoogleFonts.tajawal(
                          fontSize: 12.5,
                          color: AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Quick Select from Saved Vehicles (if user has any saved)
                      if (savedVehicles.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            isArabic ? 'سياراتك المحفوظة' : 'Saved Vehicles',
                            style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedVehicles.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (ctx, i) {
                              final v = savedVehicles[i];
                              return ActionChip(
                                avatar: const Icon(Icons.directions_car, size: 16, color: AppColors.primaryBlack),
                                label: Text(
                                  '${v.plateEmirate} ${v.plateNumber} • ${v.model}',
                                  style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: AppColors.cardBackground,
                                side: const BorderSide(color: AppColors.lightBorder),
                                onPressed: () => _selectSavedVehicle(v),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // 1. Plate Emirate & Plate Number Row
                      _buildFieldLabel(isArabic ? 'مصدر ورقم اللوحة' : 'Emirate & Plate Number'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Emirate Dropdown
                          Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.lightBorder, width: 1.2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedEmirate,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
                                style: GoogleFonts.tajawal(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlack,
                                ),
                                items: _emirates.map((e) {
                                  return DropdownMenuItem<String>(
                                    value: e['ar']!,
                                    child: Text(isArabic ? e['ar']! : e['en']!),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedEmirate = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Plate Number TextField (Clean placeholder, no hardcoded default text)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.lightBorder, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  const Text('🇦🇪', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _plateNumberController,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlack,
                                        letterSpacing: 1.2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: isArabic ? 'مثال: 12345' : 'e.g. 12345',
                                        hintStyle: GoogleFonts.tajawal(
                                          fontSize: 13,
                                          color: AppColors.secondaryText.withValues(alpha: 0.6),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        fillColor: Colors.transparent,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 2. Brand & Model Selector
                      _buildFieldLabel(isArabic ? 'براند وموديل السيارة' : 'Vehicle Brand & Model'),
                      const SizedBox(height: 8),
                      // Brand Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBrand,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlack,
                            ),
                            items: _brandModels.keys.map((brand) {
                              return DropdownMenuItem<String>(
                                value: brand,
                                child: Text(brand),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedBrand = val;
                                  if (val.contains('أخرى') || val.contains('Other')) {
                                    _isCustomModel = true;
                                  } else {
                                    _isCustomModel = false;
                                    _selectedModel = _brandModels[val]!.first;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Model Dropdown or Custom Text Input
                      if (!_isCustomModel) ...[
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
                              items: _brandModels[_selectedBrand]!.map((model) {
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
                      ] else ...[
                        // Custom Model Input Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightBorder, width: 1.2),
                          ),
                          child: TextField(
                            controller: _customModelController,
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlack,
                            ),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'اكتب موديل سيارتك هنا...' : 'Enter your car model...',
                              hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.secondaryText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // 3. Car Color: Word + Color Circle
                      _buildFieldLabel(isArabic ? 'لون السيارة (كلمة ولون)' : 'Vehicle Color'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: _carColors.firstWhere(
                              (c) => c['ar'] == _selectedColorNameAr,
                              orElse: () => _carColors.first,
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
                            items: _carColors.map((c) {
                              final color = c['color'] as Color;
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: c,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color == Colors.white ? const Color(0xFFCCCCCC) : Colors.transparent,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isArabic ? c['ar'] : c['en'],
                                      style: GoogleFonts.tajawal(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedColorNameAr = val['ar'];
                                  _selectedColorNameEn = val['en'];
                                  _selectedColorVal = val['color'];
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. Save to Favorite Vehicles Checkbox
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _saveToFavorites,
                              activeColor: AppColors.primaryBlack,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              onChanged: (v) => setState(() => _saveToFavorites = v ?? true),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _saveToFavorites = !_saveToFavorites),
                                child: Text(
                                  isArabic
                                      ? 'حفظ هذه السيارة في سياراتي المفضلة'
                                      : 'Save this vehicle to My Favorites',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Next Button "التالي لمتابعة المنيو"
                      ElevatedButton(
                        onPressed: _proceedToMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isArabic ? 'متابعة لاختيار القهوة ➔' : 'Proceed to Menu ➔',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              N8BottomNav(
                currentIndex: 0,
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

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
