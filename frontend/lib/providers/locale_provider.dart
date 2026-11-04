import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_locale') ?? 'ar';
    state = Locale(langCode);
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', languageCode);
    state = Locale(languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'ar') {
      setLocale('en');
    } else {
      setLocale('ar');
    }
  }

  bool get isArabic => state.languageCode == 'ar';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
