import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final MenuItemModel item;

  const ProductDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _selectedSizeIndex = 2; // Default to 'L'
  int _quantity = 1;
  bool _extraShot = true;
  bool _oatMilk = true;
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _sizes = [
    {'size': 'S', 'price': 16.0},
    {'size': 'M', 'price': 20.0},
    {'size': 'L', 'price': 24.0},
  ];

  double get _currentPrice {
    double base = (_sizes[_selectedSizeIndex]['price'] as double);
    if (_extraShot) base += 4.0;
    if (_oatMilk) base += 3.0;
    return base * _quantity;
  }

  void _addToCart() {
    final sizeName = _sizes[_selectedSizeIndex]['size'];
    final optionsList = <String>[];
    if (_extraShot) optionsList.add('Extra Shot');
    if (_oatMilk) optionsList.add('Oat Milk');

    ref.read(cartProvider.notifier).addItem(
          CartItem(
            productId: widget.item.id,
            nameEn: '${widget.item.nameEn} ($sizeName)',
            nameAr: '${widget.item.nameAr} ($sizeName)',
            price: _currentPrice / _quantity,
            quantity: _quantity,
            specialInstructions: optionsList.join(', '),
          ),
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryBlack),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? AppColors.errorRed : AppColors.primaryBlack,
                        size: 24,
                      ),
                      onPressed: () => setState(() => _isFavorite = !_isFavorite),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Large Hero Ceramic Cup Shot with N8 Logo style
                      Center(
                        child: Container(
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(widget.item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Product Title
                      Text(
                        widget.item.nameEn,
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Arabic & English Description
                      Text(
                        widget.item.descriptionAr,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Size Section (الحجم)
                      Text(
                        isArabic ? 'الحجم' : 'Size',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: List.generate(_sizes.length, (index) {
                          final isSelected = _selectedSizeIndex == index;
                          final s = _sizes[index];
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 0 : 6,
                                right: index == _sizes.length - 1 ? 0 : 6,
                              ),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedSizeIndex = index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryBlack : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryBlack : AppColors.lightBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        s['size'],
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : AppColors.primaryBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(s['price'] as double).toInt()} AED',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white70 : AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Add-ons Section (الإضافات)
                      Text(
                        isArabic ? 'الإضافات' : 'Add-ons',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Add-on 1: Extra Shot
                      _buildAddonOption(
                        title: isArabic ? 'شوت إضافي +4' : 'Extra Shot +4 AED',
                        isSelected: _extraShot,
                        onToggle: () => setState(() => _extraShot = !_extraShot),
                      ),
                      const SizedBox(height: 8),

                      // Add-on 2: Plant Milk
                      _buildAddonOption(
                        title: isArabic ? 'حليب نباتي +3' : 'Plant-based Milk +3 AED',
                        isSelected: _oatMilk,
                        onToggle: () => setState(() => _oatMilk = !_oatMilk),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Bar with Quantity Selector and Black Add-to-Cart Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(
                    top: BorderSide(color: AppColors.lightBorder, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Quantity counter (- 1 +)
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18, color: AppColors.primaryBlack),
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                          Text(
                            '$_quantity',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18, color: AppColors.primaryBlack),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Add to Cart Solid Black CTA Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: Text(
                          isArabic
                              ? 'أضف للسلة - ${_currentPrice.toInt()} AED'
                              : 'Add to Cart - ${_currentPrice.toInt()} AED',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _buildAddonOption({
    required String title,
    required bool isSelected,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlack : AppColors.lightBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryBlack : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlack : AppColors.lightBorder,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
