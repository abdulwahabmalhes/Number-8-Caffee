import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/n8_bottom_nav.dart';
import '../widgets/n8_popup.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'orders_history_screen.dart';
import 'loyalty_tier_screen.dart';
import 'loyalty_punch_screen.dart';
import 'profile_screen.dart';
import '../widgets/n8_drawer.dart';

class OptionItemModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final double additionalPrice;

  const OptionItemModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.additionalPrice,
  });

  factory OptionItemModel.fromJson(Map<String, dynamic> json) {
    return OptionItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      additionalPrice: double.tryParse(json['additional_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OptionGroupModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final bool isMultiple;
  final bool isRequired;
  final List<OptionItemModel> options;

  const OptionGroupModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.isMultiple,
    required this.isRequired,
    required this.options,
  });

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return OptionGroupModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      isMultiple: json['is_multiple'] == true || json['is_multiple'] == 1 || json['is_multiple'] == '1',
      isRequired: json['is_required'] == true || json['is_required'] == 1 || json['is_required'] == '1',
      options: rawOptions.map((o) => OptionItemModel.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }
}

class MenuItemModel {
  final int id;
  final String nameEn;
  final String nameAr;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final String category;
  final String imageUrl;
  final List<OptionGroupModel> optionGroups;

  const MenuItemModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.optionGroups = const [],
  });
}

class MenuScreen extends ConsumerStatefulWidget {
  final String orderType;
  final String? tableNumber;

  const MenuScreen({
    super.key,
    this.orderType = 'table',
    this.tableNumber,
  });

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProductDetails(MenuItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(item: item),
      ),
    );
  }

  void _quickAddToCart(MenuItemModel item) {
    ref.read(cartProvider.notifier).addItem(
          CartItem(
            productId: item.id,
            nameEn: item.nameEn,
            nameAr: item.nameAr,
            price: item.price,
            quantity: 1,
            image: item.imageUrl,
          ),
        );

    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    N8Popup.showSuccess(
      context: context,
      title: isArabic ? 'تمت الإضافة إلى السلة بنجاح' : 'Added to Cart Successfully',
      message: isArabic ? 'تمت إضافة ${item.nameAr} إلى سلة طلبك' : '${item.nameEn} has been added to your cart.',
      primaryBtnText: isArabic ? 'عرض السلة وإتمام الطلب' : 'View Cart & Checkout',
      onPrimaryAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
      secondaryBtnText: isArabic ? 'متابعة التسوق' : 'Continue Shopping',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final cartItemsCount = ref.watch(cartProvider).fold<int>(0, (sum, item) => sum + item.quantity);
    final menuAsync = ref.watch(menuProvider);

    return menuAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryBlack),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'جاري تحميل قائمة الطعام...' : 'Loading menu...',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.secondaryText),
                const SizedBox(height: 16),
                Text(
                  isArabic ? 'فشل الاتصال بالخادم' : 'Failed to connect to server',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic ? 'تأكد من تشغيل خادم الباك إند والمحاولة مرة أخرى.' : 'Please ensure the backend server is running and try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(menuProvider),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    isArabic ? 'إعادة المحاولة' : 'Try Again',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (categoriesData) {
        // Build dynamic categories list
        final List<Map<String, String>> categoriesList = [
          {'ar': 'الجميع', 'en': 'All'},
        ];
        
        final List<MenuItemModel> productsList = [];

        for (var cat in categoriesData) {
          final catAr = cat['name_ar'] ?? cat['name_en'] ?? '';
          final catEn = cat['name_en'] ?? '';
          categoriesList.add({'ar': catAr, 'en': catEn});

          if (cat['products'] != null) {
            for (var prod in cat['products']) {
              String rawImg = (prod['image'] ?? '').toString().trim();
              String finalImg = 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop';
              if (rawImg.isNotEmpty) {
                if (rawImg.startsWith('http://') || rawImg.startsWith('https://')) {
                  finalImg = rawImg;
                } else {
                  final cleanPath = rawImg.startsWith('/') ? rawImg.substring(1) : rawImg;
                  finalImg = 'https://no8.ae/$cleanPath';
                }
              }

              List<OptionGroupModel> parsedOptionGroups = [];
              if (prod['option_groups'] != null && prod['option_groups'] is List) {
                parsedOptionGroups = (prod['option_groups'] as List)
                    .map((og) => OptionGroupModel.fromJson(og as Map<String, dynamic>))
                    .toList();
              }

              productsList.add(MenuItemModel(
                id: prod['id'],
                nameEn: prod['name_en'] ?? '',
                nameAr: prod['name_ar'] ?? '',
                descriptionAr: prod['description_ar'] ?? '',
                descriptionEn: prod['description_en'] ?? '',
                price: double.tryParse(prod['price'].toString()) ?? 0.0,
                category: catAr, // Use Arabic category name as identifier
                imageUrl: finalImg,
                optionGroups: parsedOptionGroups,
              ));
            }
          }
        }

        // Keep _selectedCategoryIndex in range of dynamically fetched categories
        final safeCategoryIndex = _selectedCategoryIndex < categoriesList.length 
            ? _selectedCategoryIndex 
            : 0;

        final filteredProducts = productsList.where((p) {
          final matchesCat = safeCategoryIndex == 0 || 
              p.category == categoriesList[safeCategoryIndex]['ar'];
          final matchesSearch = _searchQuery.isEmpty ||
              p.nameAr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCat && matchesSearch;
        }).toList();

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: const N8Drawer(),
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // Header with Search bar and Hamburger icon
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
                    child: Row(
                      children: [
                        // Search Input Box
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.lightBorder, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(Icons.search, color: AppColors.secondaryText, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (v) => setState(() => _searchQuery = v),
                                    style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.primaryBlack),
                                    decoration: InputDecoration(
                                      hintText: isArabic ? 'ابحث عن منتج' : 'Search for a product...',
                                      hintStyle: GoogleFonts.tajawal(fontSize: 13, color: AppColors.secondaryText),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Menu/Side icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.lightBorder, width: 1.2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.primaryBlack, size: 22),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories Horizontal Scroll List
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: categoriesList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = safeCategoryIndex == index;
                        final catName = isArabic ? categoriesList[index]['ar']! : categoriesList[index]['en']!;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlack : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlack : AppColors.lightBorder,
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              catName,
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.primaryBlack,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2-Column Product Grid
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              isArabic ? 'لا توجد منتجات متوفرة' : 'No products available',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final prod = filteredProducts[index];
                              return _buildProductCard(prod, isArabic);
                            },
                          ),
                  ),

                  // Floating Cart Bar when items exist
                  if (ref.watch(cartProvider).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    isArabic
                                        ? '${ref.watch(cartProvider).length} أصناف في السلة'
                                        : '${ref.watch(cartProvider).length} items in cart',
                                    style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${ref.watch(cartProvider.notifier).totalAmount.toInt()} AED',
                                    style: GoogleFonts.dmSans(color: AppColors.goldAccent, fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isArabic ? 'الدفع ➔' : 'Checkout ➔',
                                    style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Bottom Navigation
                  N8BottomNav(
                    currentIndex: _currentNavIndex,
                    onTap: (index) {
                      setState(() => _currentNavIndex = index);
                      if (index == 0) {
                        // Current Menu
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
            // Floating Cart Action Button if items in cart
            floatingActionButton: cartItemsCount > 0
                ? FloatingActionButton.extended(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    backgroundColor: AppColors.primaryBlack,
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    label: Text(
                      isArabic ? 'السلة ($cartItemsCount)' : 'Cart ($cartItemsCount)',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildProductCard(MenuItemModel prod, bool isArabic) {
    return GestureDetector(
      onTap: () => _openProductDetails(prod),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: Image.network(
                  prod.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(Icons.local_cafe_outlined, size: 40, color: AppColors.secondaryText),
                    ),
                  ),
                ),
              ),
            ),

            // Product Details Bar at Bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? prod.nameAr : prod.nameEn,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${prod.price.toInt()} AED',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Round Black "+" Add Button
                  GestureDetector(
                    onTap: () => _quickAddToCart(prod),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlack,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
