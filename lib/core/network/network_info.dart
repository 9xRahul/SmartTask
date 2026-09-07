import 'package:connectivity_plus/connectivity_plus.dart';

/// Contract for checking device network connectivity.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// Implementation using [Connectivity] plugin from connectivity_plus.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final List<ConnectivityResult> results = await connectivity.checkConnectivity();
    return _hasValidConnection(results);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }

  bool _hasValidConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    for (final ConnectivityResult result in results) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn) {
        return true;
      }
    }
    return false;
  }
}
