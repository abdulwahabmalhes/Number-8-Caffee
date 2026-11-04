import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String prodDomain = 'https://no8.ae';

  static String _getDefaultIp() {
    return prodDomain;
  }

  static String _serverIp = prodDomain;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    var savedIp = prefs.getString('server_ip');
    if (savedIp == null || savedIp == '127.0.0.1' || savedIp == '192.168.0.138' || savedIp == '192.168.0.137' || savedIp.isEmpty) {
      savedIp = _getDefaultIp();
      await prefs.setString('server_ip', savedIp);
    }
    _serverIp = savedIp;
    _dio.options.baseUrl = baseUrl;
    
    final token = prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static String get serverIp => _serverIp;

  static String get baseUrl {
    final clean = _serverIp.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      if (clean.endsWith('/api/v1')) {
        return clean;
      }
      return clean.endsWith('/') ? '${clean}api/v1' : '$clean/api/v1';
    }
    return 'http://$clean:8000/api/v1';
  }

  static Future<void> updateServerIp(String ip) async {
    _serverIp = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
    _dio.options.baseUrl = baseUrl;
  }

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://no8.ae/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static Dio get instance {
    _dio.options.baseUrl = baseUrl;
    return _dio;
  }

  static void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
}
