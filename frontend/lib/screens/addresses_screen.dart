import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  void _showAddAddressDialog(BuildContext context, WidgetRef ref, bool isArabic) {
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();

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
                isArabic ? 'إضافة عنوان جديد' : 'Add New Address',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم العنوان (مثال: المنزل، العمل)' : 'Address Label (e.g. Home, Office)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isArabic ? 'تفاصيل العنوان (المدينة، الشارع، المبنى)' : 'Address Details (City, Street, Building)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty && detailsCtrl.text.trim().isNotEmpty) {
                    ref.read(userDataProvider.notifier).addAddress(
                          AddressItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleCtrl.text.trim(),
                            details: detailsCtrl.text.trim(),
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
                  isArabic ? 'حفظ العنوان' : 'Save Address',
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
    final addresses = ref.watch(userDataProvider).addresses;

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
            isArabic ? 'عناويني' : 'My Addresses',
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
                child: addresses.isEmpty
                    ? Center(
                        child: Text(
                          isArabic ? 'لا توجد عناوين محفوظة' : 'No saved addresses',
                          style: GoogleFonts.tajawal(color: AppColors.secondaryText),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
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
                                  child: const Icon(Icons.location_on_outlined, color: AppColors.primaryBlack),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        addr.title,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        addr.details,
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
                                    ref.read(userDataProvider.notifier).removeAddress(addr.id);
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
                  onPressed: () => _showAddAddressDialog(context, ref, isArabic),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    isArabic ? 'إضافة عنوان جديد' : 'Add New Address',
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
