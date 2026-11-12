import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartProvider.notifier).totalAmount;
    final double serviceFee = cartItems.isNotEmpty ? 2.0 : 0.0;
    final total = subtotal + serviceFee;

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

                    // Price Breakdown and Solid Black "الدفع الآن" CTA Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            title: isArabic ? 'رسوم الخدمة' : 'Service Fee',
                            amount: '${serviceFee.toInt()} AED',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.lightBorder, height: 1),
                          ),
                          _buildSummaryRow(
                            title: isArabic ? 'الإجمالي' : 'Total',
                            amount: '${total.toInt()} AED',
                            isTotal: true,
                          ),
                          const SizedBox(height: 20),

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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.primaryBlack : AppColors.secondaryText,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.dmSans(
            fontSize: isTotal ? 17 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }
}
