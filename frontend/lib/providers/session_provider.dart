import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  final bool isAuthenticated;
  final String? sessionId;
  final String? branchName;
  final int? branchId;
  final String? tableNumber;
  final int? tableId;
  final String orderType; // 'table' | 'car' | 'pickup'
  final Map<String, dynamic>? vehicleDetails;

  SessionState({
    this.isAuthenticated = false,
    this.sessionId,
    this.branchName = 'Al Khabisi Branch',
    this.branchId,
    this.tableNumber,
    this.tableId,
    this.orderType = 'table',
    this.vehicleDetails,
  });

  SessionState copyWith({
    bool? isAuthenticated,
    String? sessionId,
    String? branchName,
    int? branchId,
    String? tableNumber,
    int? tableId,
    String? orderType,
    Map<String, dynamic>? vehicleDetails,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      sessionId: sessionId ?? this.sessionId,
      branchName: branchName ?? this.branchName,
      branchId: branchId ?? this.branchId,
      tableNumber: tableNumber ?? this.tableNumber,
      tableId: tableId ?? this.tableId,
      orderType: orderType ?? this.orderType,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    final branchName = prefs.getString('branch_name') ?? 'Al Khabisi Branch';
    final branchId = prefs.getInt('branch_id');
    final tableNumber = prefs.getString('table_number');
    final tableId = prefs.getInt('table_id');
    final orderType = prefs.getString('order_type') ?? 'table';

    if (sessionId != null || tableNumber != null) {
      state = SessionState(
        isAuthenticated: true,
        sessionId: sessionId ?? 'sess-${DateTime.now().millisecondsSinceEpoch}',
        branchName: branchName,
        branchId: branchId,
        tableNumber: tableNumber,
        tableId: tableId,
        orderType: orderType,
      );
    }
  }

  void startTableSession({
    required String tableNumber,
    required int tableId,
    required String sessionId,
    required String branchName,
    required int branchId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
    await prefs.setString('table_number', tableNumber);
    await prefs.setInt('table_id', tableId);
    await prefs.setString('branch_name', branchName);
    await prefs.setInt('branch_id', branchId);
    await prefs.setString('order_type', 'table');

    state = SessionState(
      isAuthenticated: true,
      sessionId: sessionId,
      branchName: branchName,
      branchId: branchId,
      tableNumber: tableNumber,
      tableId: tableId,
      orderType: 'table',
    );
  }

  void startCarService(Map<String, dynamic> vehicleDetails) async {
    final prefs = await SharedPreferences.getInstance();
    final sessId = 'car-sess-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('session_id', sessId);
    await prefs.setString('order_type', 'car');

    state = SessionState(
      isAuthenticated: true,
      sessionId: sessId,
      branchName: 'Al Khabisi Branch',
      branchId: 1,
      orderType: 'car',
      vehicleDetails: vehicleDetails,
    );
  }

  void startPickupSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessId = 'pickup-sess-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('session_id', sessId);
    await prefs.setString('order_type', 'pickup');

    state = SessionState(
      isAuthenticated: true,
      sessionId: sessId,
      branchName: 'Al Khabisi Branch',
      branchId: 1,
      orderType: 'pickup',
    );
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
