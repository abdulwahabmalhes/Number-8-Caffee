import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  void _showAddVehicleDialog(BuildContext context, WidgetRef ref, bool isArabic) {
    final plateCtrl = TextEditingController();
    final emirateCtrl = TextEditingController(text: 'أبوظبي');
    final modelCtrl = TextEditingController();
    final colorCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'إضافة سيارة جديدة' : 'Add New Vehicle',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: plateCtrl,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'رقم اللوحة' : 'Plate Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: emirateCtrl,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الإمارة / الرمز' : 'Emirate / Code',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelCtrl,
                decoration: InputDecoration(
                  labelText: isArabic ? 'نوع وموديل السيارة (مثال: نيسان باترول)' : 'Car Model (e.g. Nissan Patrol)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorCtrl,
                decoration: InputDecoration(
                  labelText: isArabic ? 'لون السيارة' : 'Car Color',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (plateCtrl.text.trim().isNotEmpty && modelCtrl.text.trim().isNotEmpty) {
                    ref.read(userDataProvider.notifier).addVehicle(
                          VehicleItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            plateNumber: plateCtrl.text.trim(),
                            plateEmirate: emirateCtrl.text.trim(),
                            model: modelCtrl.text.trim(),
                            color: colorCtrl.text.trim(),
                          ),
                        );
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  isArabic ? 'حفظ السيارة' : 'Save Vehicle',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final vehicles = ref.watch(userDataProvider).vehicles;

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
            isArabic ? 'سياراتي' : 'My Vehicles',
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
                child: vehicles.isEmpty
                    ? Center(
                        child: Text(
                          isArabic ? 'لا توجد سيارات محفوظة' : 'No saved vehicles',
                          style: GoogleFonts.tajawal(color: AppColors.secondaryText),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: vehicles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final v = vehicles[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.directions_car_outlined, color: AppColors.primaryBlack),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.model,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${v.plateEmirate} - ${v.plateNumber} (${v.color})',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 13,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () {
                                    ref.read(userDataProvider.notifier).removeVehicle(v.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddVehicleDialog(context, ref, isArabic),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    isArabic ? 'إضافة سيارة جديدة' : 'Add New Vehicle',
                    style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
