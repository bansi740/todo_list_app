import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal() {
    _connectivity.onConnectivityChanged.listen((status) {
      _isOnlineController.add(status != ConnectivityResult.none);
    });
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _isOnlineController = StreamController<bool>.broadcast();

  // Stream to listen for connectivity changes
  Stream<bool> get onConnectivityChanged => _isOnlineController.stream;

  // Check if currently online
  static Future<bool> get isOnline async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Dispose stream
  void dispose() {
    _isOnlineController.close();
  }
}