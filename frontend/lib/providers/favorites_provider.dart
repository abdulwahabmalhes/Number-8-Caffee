import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProduct {
  final int id;
  final String nameAr;
  final String nameEn;
  final double price;
  final String image;
  final String? category;

  FavoriteProduct({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.image,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'price': price,
        'image': image,
        'category': category,
      };

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) => FavoriteProduct(
        id: json['id'],
        nameAr: json['nameAr'] ?? '',
        nameEn: json['nameEn'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        image: json['image'] ?? '',
        category: json['category'],
      );
}

class FavoritesNotifier extends StateNotifier<List<FavoriteProduct>> {
  FavoritesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final favStr = prefs.getString('user_favorites');
    if (favStr != null) {
      try {
        final List list = jsonDecode(favStr);
        state = list.map((e) => FavoriteProduct.fromJson(e)).toList();
      } catch (_) {}
    } else {
      // Default sample favorite items
      state = [
        FavoriteProduct(
          id: 1,
          nameAr: 'سبانش لاتيه بارد',
          nameEn: 'Iced Spanish Latte',
          price: 26.0,
          image: 'assets/images/intro_brew.jpg',
          category: 'قهوة باردة',
        ),
        FavoriteProduct(
          id: 2,
          nameAr: 'فلات وايت',
          nameEn: 'Flat White',
          price: 22.0,
          image: 'assets/images/intro_table.jpg',
          category: 'قهوة ساخنة',
        ),
      ];
    }
  }

  Future<void> toggleFavorite(FavoriteProduct product) async {
    final exists = state.any((e) => e.id == product.id);
    List<FavoriteProduct> updated;
    if (exists) {
      updated = state.where((e) => e.id != product.id).toList();
    } else {
      updated = [...state, product];
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_favorites', jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  bool isFavorite(int id) {
    return state.any((e) => e.id == id);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteProduct>>((ref) {
  return FavoritesNotifier();
});
