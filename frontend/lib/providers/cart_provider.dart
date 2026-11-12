import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedOption {
  final int id;
  final String nameAr;
  final String nameEn;
  final double price;
  final String groupNameAr;
  final String groupNameEn;

  SelectedOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    this.groupNameAr = '',
    this.groupNameEn = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_ar': nameAr,
    'name_en': nameEn,
    'price': price,
    'group_name_ar': groupNameAr,
    'group_name_en': groupNameEn,
  };

  factory SelectedOption.fromJson(Map<String, dynamic> json) => SelectedOption(
    id: json['id'] ?? 0,
    nameAr: json['name_ar'] ?? '',
    nameEn: json['name_en'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    groupNameAr: json['group_name_ar'] ?? '',
    groupNameEn: json['group_name_en'] ?? '',
  );
}

class CartItem {
  final int productId;
  final String nameEn;
  final String nameAr;
  final double price;
  final int quantity;
  final String image;
  final List<SelectedOption> selectedOptions;
  final String? specialInstructions;

  CartItem({
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    this.quantity = 1,
    this.image = '',
    this.selectedOptions = const [],
    this.specialInstructions,
  });

  String get optionsKey {
    final ids = selectedOptions.map((o) => o.id).toList()..sort();
    return '$productId-${ids.join(',')}-${specialInstructions ?? ''}';
  }

  String get optionsSummaryAr {
    return selectedOptions.map((o) {
      if (o.price > 0) {
        return '${o.nameAr} (+${o.price.toStringAsFixed(0)})';
      }
      return o.nameAr;
    }).join(' • ');
  }

  String get optionsSummaryEn {
    return selectedOptions.map((o) {
      if (o.price > 0) {
        return '${o.nameEn} (+${o.price.toStringAsFixed(0)})';
      }
      return o.nameEn;
    }).join(' • ');
  }

  CartItem copyWith({
    int? quantity,
    String? image,
    List<SelectedOption>? selectedOptions,
    String? specialInstructions,
  }) {
    return CartItem(
      productId: productId,
      nameEn: nameEn,
      nameAr: nameAr,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    // Check if identical item exists (same product id, options, special instructions)
    final existingIndex = state.indexWhere((i) => i.optionsKey == item.optionsKey);
    
    if (existingIndex >= 0) {
      final updated = List<CartItem>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + item.quantity
      );
      state = updated;
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    final updated = List<CartItem>.from(state);
    updated[index] = updated[index].copyWith(quantity: quantity);
    state = updated;
  }

  void removeItem(int index) {
    final updated = List<CartItem>.from(state);
    updated.removeAt(index);
    state = updated;
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
