import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard_controller.dart';
import '../test/duty_test.dart' as fixtures;

class PreviewUser extends fixtures.TestUser {
  final String role;
  PreviewUser(this.role);
  @override
  String get userName => 'Amit Kumar';
  @override
  String get userType => role;
}
class PreviewDuty extends fixtures.TestDuty {
  PreviewDuty() : super(fixtures.FakeApi(), fixtures.MemoryStore()) { ready = true; }
  @override
  Future<void> reconcile({bool silent = false}) async {}
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('dashboard_preview');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'), (_) async => dir.path);
    await GetStorage.init();
    for (final entry in {'Roboto': 'roboto-regular.ttf', 'MaterialIcons': 'materialicons-regular.otf'}.entries) {
      final loader = FontLoader(entry.key)..addFont(Future.value(ByteData.sublistView(await File('.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/${entry.value}').readAsBytes())));
      await loader.load();
    }
  });
  for (final role in ['delivery_partner', 'delivery_boy', 'head']) {
    for (final width in [320.0, 390.0, 768.0]) {
      testWidgets('$role dashboard fits $width', (tester) async {
        Get.testMode = true;
        await tester.binding.setSurfaceSize(Size(width, 844));
        Get.put<UserController>(PreviewUser(role));
        Get.put<DashboardController>(DashboardController());
        Get.put<DutyController>(PreviewDuty());
        await tester.pumpWidget(GetMaterialApp(home: RepaintBoundary(child: const DashboardScreen())));
        await tester.pumpAndSettle();
        expect(find.text('Hello Amit Kumar'), findsOneWidget);
        expect(find.text('Total Duty'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (role == 'delivery_partner' && width == 390) {
          await tester.runAsync(() async {
            final boundary = tester.firstRenderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('tmp/dashboard-home-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.scrollUntilVisible(find.text('Expense Management'), 250, scrollable: find.byType(Scrollable).first);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await Get.delete<DutyController>(force: true); Get.reset();
        await tester.binding.setSurfaceSize(null);
      });
    }
  }
}


