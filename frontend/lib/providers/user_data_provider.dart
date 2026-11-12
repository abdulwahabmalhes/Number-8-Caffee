import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressItem {
  final String id;
  final String title;
  final String details;
  final String? note;
  final bool isDefault;

  AddressItem({
    required this.id,
    required this.title,
    required this.details,
    this.note,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'details': details,
        'note': note,
        'isDefault': isDefault,
      };

  factory AddressItem.fromJson(Map<String, dynamic> json) => AddressItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        details: json['details'] ?? '',
        note: json['note'],
        isDefault: json['isDefault'] ?? false,
      );
}

class VehicleItem {
  final String id;
  final String plateNumber;
  final String plateEmirate;
  final String model;
  final String color;

  VehicleItem({
    required this.id,
    required this.plateNumber,
    required this.plateEmirate,
    required this.model,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'plateNumber': plateNumber,
        'plateEmirate': plateEmirate,
        'model': model,
        'color': color,
      };

  factory VehicleItem.fromJson(Map<String, dynamic> json) => VehicleItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        plateNumber: json['plateNumber'] ?? '',
        plateEmirate: json['plateEmirate'] ?? 'أبوظبي',
        model: json['model'] ?? '',
        color: json['color'] ?? '',
      );
}

class UserDataState {
  final List<AddressItem> addresses;
  final List<VehicleItem> vehicles;

  UserDataState({
    this.addresses = const [],
    this.vehicles = const [],
  });

  UserDataState copyWith({
    List<AddressItem>? addresses,
    List<VehicleItem>? vehicles,
  }) {
    return UserDataState(
      addresses: addresses ?? this.addresses,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}

class UserDataNotifier extends StateNotifier<UserDataState> {
  UserDataNotifier() : super(UserDataState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final addrStr = prefs.getString('saved_addresses');
    final vehStr = prefs.getString('saved_vehicles');

    List<AddressItem> addresses = [];
    List<VehicleItem> vehicles = [];

    if (addrStr != null) {
      try {
        final List list = jsonDecode(addrStr);
        addresses = list.map((e) => AddressItem.fromJson(e)).toList();
      } catch (_) {}
    }

    if (vehStr != null) {
      try {
        final List list = jsonDecode(vehStr);
        vehicles = list.map((e) => VehicleItem.fromJson(e)).toList();
      } catch (_) {}
    }

    state = UserDataState(addresses: addresses, vehicles: vehicles);
  }

  Future<void> addAddress(AddressItem address) async {
    final updated = [...state.addresses, address];
    state = state.copyWith(addresses: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_addresses', jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  Future<void> removeAddress(String id) async {
    final updated = state.addresses.where((e) => e.id != id).toList();
    state = state.copyWith(addresses: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_addresses', jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  Future<void> addVehicle(VehicleItem vehicle) async {
    final updated = [...state.vehicles, vehicle];
    state = state.copyWith(vehicles: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_vehicles', jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  Future<void> removeVehicle(String id) async {
    final updated = state.vehicles.where((e) => e.id != id).toList();
    state = state.copyWith(vehicles: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_vehicles', jsonEncode(updated.map((e) => e.toJson()).toList()));
  }
}

final userDataProvider = StateNotifierProvider<UserDataNotifier, UserDataState>((ref) {
  return UserDataNotifier();
});
