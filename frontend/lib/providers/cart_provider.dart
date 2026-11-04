import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final int productId;
  final String nameEn;
  final String nameAr;
  final double price;
  final int quantity;
  final String? specialInstructions;
  // TODO: Add selected options

  CartItem({
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    this.quantity = 1,
    this.specialInstructions,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      nameEn: nameEn,
      nameAr: nameAr,
      price: price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    // Check if identical item exists (same product id, options)
    final existingIndex = state.indexWhere((i) => i.productId == item.productId && i.specialInstructions == item.specialInstructions);
    
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
