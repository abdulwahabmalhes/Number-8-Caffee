import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final favorites = ref.watch(favoritesProvider);

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
            isArabic ? 'المفضلة' : 'Favorites',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 64, color: AppColors.secondaryText),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'لا توجد منتجات في المفضلة' : 'No favorite items yet',
                        style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: AppColors.lightBorder,
                                child: const Icon(Icons.local_cafe, color: AppColors.secondaryText),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? item.nameAr : item.nameEn,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.price.toInt()} AED',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: AppColors.primaryBlack),
                            onPressed: () {
                              ref.read(cartProvider.notifier).addItem(
                                    CartItem(
                                      productId: item.id,
                                      nameAr: item.nameAr,
                                      nameEn: item.nameEn,
                                      price: item.price,
                                      quantity: 1,
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic ? 'تمت الإضافة إلى السلة' : 'Added to cart',
                                    style: GoogleFonts.tajawal(),
                                  ),
                                  duration: const Duration(seconds: 1),
                                  action: SnackBarAction(
                                    label: isArabic ? 'السلة' : 'Cart',
                                    textColor: AppColors.goldAccent,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CartScreen()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              ref.read(favoritesProvider.notifier).toggleFavorite(item);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
