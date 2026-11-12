import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
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
  int _quantity = 1;
  // Map of groupId -> single selected optionId
  final Map<int, int> _singleSelections = {};
  // Map of groupId -> Set of selected optionIds (for multiple choice)
  final Map<int, Set<int>> _multiSelections = {};

  @override
  void initState() {
    super.initState();
    _initDefaultSelections();
  }

  void _initDefaultSelections() {
    for (final group in widget.item.optionGroups) {
      if (!group.isMultiple && group.options.isNotEmpty) {
        // Pre-select first option for single-choice groups (e.g. Beans or Temp)
        _singleSelections[group.id] = group.options.first.id;
      } else if (group.isMultiple) {
        _multiSelections[group.id] = {};
      }
    }
  }

  List<SelectedOption> get _gatheredSelectedOptions {
    final list = <SelectedOption>[];

    for (final group in widget.item.optionGroups) {
      if (!group.isMultiple) {
        final optId = _singleSelections[group.id];
        if (optId != null) {
          final opt = group.options.firstWhere(
            (o) => o.id == optId,
            orElse: () => group.options.first,
          );
          list.add(SelectedOption(
            id: opt.id,
            nameAr: opt.nameAr,
            nameEn: opt.nameEn,
            price: opt.additionalPrice,
            groupNameAr: group.nameAr,
            groupNameEn: group.nameEn,
          ));
        }
      } else {
        final set = _multiSelections[group.id] ?? {};
        for (final optId in set) {
          final opt = group.options.firstWhere((o) => o.id == optId);
          list.add(SelectedOption(
            id: opt.id,
            nameAr: opt.nameAr,
            nameEn: opt.nameEn,
            price: opt.additionalPrice,
            groupNameAr: group.nameAr,
            groupNameEn: group.nameEn,
          ));
        }
      }
    }

    return list;
  }

  double get _currentUnitPrice {
    double base = widget.item.price;
    for (final opt in _gatheredSelectedOptions) {
      base += opt.price;
    }
    return base;
  }

  double get _currentTotalPrice {
    return _currentUnitPrice * _quantity;
  }

  void _addToCart() {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final options = _gatheredSelectedOptions;
    final optionsSummary = isArabic
        ? options.map((o) => o.nameAr).join(', ')
        : options.map((o) => o.nameEn).join(', ');

    ref.read(cartProvider.notifier).addItem(
          CartItem(
            productId: widget.item.id,
            nameEn: widget.item.nameEn,
            nameAr: widget.item.nameAr,
            price: _currentUnitPrice,
            quantity: _quantity,
            image: widget.item.imageUrl,
            selectedOptions: options,
            specialInstructions: optionsSummary.isNotEmpty ? optionsSummary : null,
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
    final isFav = ref.watch(favoritesProvider).any((p) => p.id == widget.item.id);

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
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.errorRed : AppColors.primaryBlack,
                        size: 24,
                      ),
                      onPressed: () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(
                              FavoriteProduct(
                                id: widget.item.id,
                                nameAr: widget.item.nameAr,
                                nameEn: widget.item.nameEn,
                                price: widget.item.price,
                                image: widget.item.imageUrl,
                                category: widget.item.category,
                              ),
                            );
                      },
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
                      // Product Image Hero
                      Center(
                        child: Container(
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.cardBackground,
                            border: Border.all(color: AppColors.lightBorder),
                            image: DecorationImage(
                              image: NetworkImage(widget.item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Product Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? widget.item.nameAr : widget.item.nameEn,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isArabic ? widget.item.nameEn : widget.item.nameAr,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlack,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${widget.item.price.toInt()} AED',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (widget.item.descriptionAr.isNotEmpty || widget.item.descriptionEn.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          isArabic ? widget.item.descriptionAr : widget.item.descriptionEn,
                          style: GoogleFonts.tajawal(
                            fontSize: 13.5,
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Dynamic Option Groups (Add-ons)
                      if (widget.item.optionGroups.isNotEmpty) ...[
                        for (final group in widget.item.optionGroups) ...[
                          _buildOptionGroupSection(group, isArabic),
                          const SizedBox(height: 18),
                        ],
                      ] else ...[
                        // Default Fallback Add-on if no groups are assigned to this product
                        _buildDefaultAddonsSection(isArabic),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Bar with Quantity Selector and Add-to-Cart Button
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
                              ? 'أضف للسلة • ${_currentTotalPrice.toInt()} AED'
                              : 'Add to Cart • ${_currentTotalPrice.toInt()} AED',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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

  Widget _buildOptionGroupSection(OptionGroupModel group, bool isArabic) {
    final groupName = isArabic ? group.nameAr : group.nameEn;
    final isMultiple = group.isMultiple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              groupName,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlack,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Text(
                isMultiple
                    ? (isArabic ? 'اختيار متعدد' : 'Multiple')
                    : (group.isRequired
                        ? (isArabic ? 'إجباري' : 'Required')
                        : (isArabic ? 'اختياري' : 'Optional')),
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (!isMultiple) ...[
          // Single choice: Render as elegant selector chips / list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.options.map((opt) {
              final isSelected = _singleSelections[group.id] == opt.id;
              final optName = isArabic ? opt.nameAr : opt.nameEn;
              final priceLabel = opt.additionalPrice > 0
                  ? '+${opt.additionalPrice.toInt()} AED'
                  : (isArabic ? 'مجاناً' : 'Free');

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _singleSelections[group.id] = opt.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlack : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlack : AppColors.lightBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        optName,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($priceLabel)',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.gold : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          // Multi choice: Render as list items with checkmarks
          Column(
            children: group.options.map((opt) {
              final selectedSet = _multiSelections[group.id] ?? {};
              final isSelected = selectedSet.contains(opt.id);
              final optName = isArabic ? opt.nameAr : opt.nameEn;
              final priceLabel = opt.additionalPrice > 0
                  ? '+${opt.additionalPrice.toInt()} AED'
                  : (isArabic ? 'مجاناً' : 'Free');

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final updated = Set<int>.from(_multiSelections[group.id] ?? {});
                      if (isSelected) {
                        updated.remove(opt.id);
                      } else {
                        updated.add(opt.id);
                      }
                      _multiSelections[group.id] = updated;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        Expanded(
                          child: Text(
                            optName,
                            style: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                        ),
                        Text(
                          priceLabel,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: opt.additionalPrice > 0 ? AppColors.gold : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultAddonsSection(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'خيارات إضافية' : 'Options',
          style: GoogleFonts.tajawal(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.coffee_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isArabic ? 'محضر يدوياً بأعلى معايير الجودة' : 'Freshly handcrafted to perfection',
                  style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
