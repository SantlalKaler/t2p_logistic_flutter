import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/conectivity_controller.dart';

class FakeConnectivity extends Fake implements Connectivity {
  final changes = StreamController<List<ConnectivityResult>>.broadcast(
    sync: true,
  );
  List<ConnectivityResult> current = [ConnectivityResult.none];
  Completer<List<ConnectivityResult>>? pendingCheck;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      pendingCheck == null ? current : pendingCheck!.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeConnectivity connectivity;
  late ConnectivityController controller;

  setUp(() {
    Get.testMode = true;
    connectivity = FakeConnectivity();
    controller = ConnectivityController(connectivity: connectivity);
  });

  tearDown(() async {
    Get.reset();
    await connectivity.changes.close();
  });

  Future<void> start() async {
    Get.put(controller);
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'loads initial status and accepts simultaneous connection types',
    () async {
      await start();
      expect(controller.isInternetAvailable.value, isFalse);
      connectivity.changes.add([
        ConnectivityResult.wifi,
        ConnectivityResult.mobile,
      ]);
      expect(controller.isInternetAvailable.value, isTrue);
      connectivity.changes.add([ConnectivityResult.none]);
      expect(controller.isInternetAvailable.value, isFalse);
      connectivity.changes.add([]);
      expect(controller.isInternetAvailable.value, isFalse);
    },
  );

  test('rechecks connectivity when the app resumes', () async {
    await start();
    connectivity.current = [ConnectivityResult.mobile];
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(controller.isInternetAvailable.value, isTrue);
  });

  test(
    'an older initial check cannot overwrite a newer stream result',
    () async {
      connectivity.pendingCheck = Completer<List<ConnectivityResult>>();
      await start();
      connectivity.changes.add([ConnectivityResult.wifi]);
      connectivity.pendingCheck!.complete([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.isInternetAvailable.value, isTrue);
    },
  );

  test('removes the platform stream subscription when disposed', () async {
    await start();
    expect(connectivity.changes.hasListener, isTrue);
    await Get.delete<ConnectivityController>(force: true);
    expect(connectivity.changes.hasListener, isFalse);
  });
}
