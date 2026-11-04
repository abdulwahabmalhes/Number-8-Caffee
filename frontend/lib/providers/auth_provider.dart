import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final Map<String, dynamic>? user;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userDataStr = prefs.getString('user_data');
    
    Map<String, dynamic>? user;
    if (userDataStr != null) {
      try {
        user = jsonDecode(userDataStr);
      } catch (_) {}
    }
    
    if (token != null) {
      ApiClient.setAuthToken(token);
      state = state.copyWith(
        isAuthenticated: true, 
        token: token,
        user: user,
      );
    }
  }

  Future<void> login(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));
    ApiClient.setAuthToken(token);
    state = state.copyWith(isAuthenticated: true, token: token, user: user);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    ApiClient.setAuthToken(null);
    state = AuthState();
  }

  Future<bool> deleteAccount() async {
    try {
      final res = await ApiClient.instance.delete('/customer/account');
      if (res.data != null && res.data['success'] == true) {
        await logout();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
