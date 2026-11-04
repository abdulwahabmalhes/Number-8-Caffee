import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

final menuProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await ApiClient.instance.get('/menu');
  if (response.data['success']) {
    return response.data['data'] as List<dynamic>;
  } else {
    throw Exception('Failed to load menu');
  }
});
