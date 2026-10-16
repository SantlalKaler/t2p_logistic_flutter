import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

class ConnectivityController extends GetxController
    with WidgetsBindingObserver {
  ConnectivityController({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final isInternetAvailable = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  int _connectionRevision = 0;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _connectionRevision++;
      _updateConnection(results);
    });
    unawaited(_refreshConnection());
  }

  Future<void> _refreshConnection() async {
    final revision = _connectionRevision;
    try {
      final results = await _connectivity.checkConnectivity();
      if (!isClosed && revision == _connectionRevision) {
        _updateConnection(results);
      }
    } catch (_) {
      // Keep the last known state when the platform query is unavailable.
    }
  }

  void _updateConnection(List<ConnectivityResult> results) {
    if (isClosed) return;
    final available = results.any(
      (result) => result != ConnectivityResult.none,
    );
    final wasAvailable = isInternetAvailable.value;
    isInternetAvailable.value = available;
    if (available == wasAvailable || Get.context == null) return;
    if (available) {
      CustomSnackBar.showSnackBar(
        CustomSnackBar.success,
        'Connection restored',
        CustomSnackBar.success,
      );
    } else {
      CustomSnackBar.showSnackBar(
        CustomSnackBar.error,
        'No connection available',
        CustomSnackBar.error,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshConnection());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    super.onClose();
  }
}
