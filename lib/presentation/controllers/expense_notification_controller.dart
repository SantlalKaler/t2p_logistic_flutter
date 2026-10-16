import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../controllers/user_controller.dart';
import '../screens/expense_management/expense_controller.dart';
import '../screens/expense_management/expense_detail.dart';

/// Uses the project's native Firebase configuration. Expenses still work when
/// a platform has no Firebase configuration or notification permission.
class ExpenseNotificationController extends GetxController {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  RemoteMessage? _pending;
  String? _registeredToken;
  bool _dashboardReady = false;

  @override
  void onReady() {
    super.onReady();
    if (Firebase.apps.isEmpty ||
        kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(_open));
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        if (message.data['type'] == 'expense' &&
            Get.find<UserController>().isLoggedIn) {
          final expenses = Get.find<ExpenseController>();
          expenses.notifyChanged('${message.data['expense_id'] ?? ''}');
          expenses.initialize();
        }
      }),
    );
    _subscriptions.add(
      // The guide's device_token endpoint expects an FCM token, not the new FID.
      // ignore: deprecated_member_use
      FirebaseMessaging.instance.onTokenRefresh.listen((_) => registerToken()),
    );
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((message) {
          if (message != null) {
            _pending = message;
            openPending();
          }
        })
        .catchError((Object e) {
          debugPrint('Expense notification startup: $e');
        });
  }

  Future<void> registerToken() async {
    if (Firebase.apps.isEmpty ||
        kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    final user = Get.find<UserController>();
    if (!user.isLoggedIn) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      // Keep the FCM token contract used by the existing backend.
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || '$token:${user.userId}' == _registeredToken) return;
      // This is the existing app token endpoint, not a /v1 expense operation.
      final response = await Get.find<ExpenseController>().apiService.post(
        'app/update-token',
        {'user_id': user.userId, 'device_token': token},
      );
      if (response?.data is Map && response!.data['status'] == 'success') {
        _registeredToken = '$token:${user.userId}';
      }
    } catch (e) {
      debugPrint('Expense notification registration unavailable: $e');
    }
  }

  void _open(RemoteMessage message) {
    if (message.data['type'] != 'expense') return;
    _pending = message;
    openPending();
  }

  void openPending() {
    if (!_dashboardReady ||
        _pending == null ||
        !Get.find<UserController>().isLoggedIn ||
        Get.context == null) {
      return;
    }
    final id = '${_pending!.data['expense_id'] ?? ''}';
    _pending = null;
    if (id.isNotEmpty) Get.to(() => ExpenseDetailScreen(id: id));
  }

  void dashboardReady() {
    _dashboardReady = true;
    registerToken();
    openPending();
  }

  void resetSession() {
    _dashboardReady = false;
    _pending = null;
    _registeredToken = null;
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }
}
