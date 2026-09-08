import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring device connectivity changes and notifying subscribers.
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectionChangeController = StreamController<bool>.broadcast();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isCurrentlyConnected = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get isConnected => _isCurrentlyConnected;
  Stream<bool> get onConnectivityChanged => _connectionChangeController.stream;

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    checkConnection();
  }

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isCurrentlyConnected;
    } catch (_) {
      return _isCurrentlyConnected;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool newState = _hasValidConnection(results);
    _isCurrentlyConnected = newState;

    if (!_connectionChangeController.isClosed) {
      _connectionChangeController.add(newState);
    }
  }

  bool _hasValidConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    for (final result in results) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.vpn) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _subscription.cancel();
    _connectionChangeController.close();
  }
}
