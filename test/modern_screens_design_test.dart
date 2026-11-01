import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/domain/Model/partner/CodExpenseListResponse.dart'
    as cod;
import 'package:t2p_logistic/domain/Model/partner/FinancialLogResponse.dart';
import 'package:t2p_logistic/domain/Model/partner/purchase_inward/PurchaseInwardListResponse.dart';
import 'package:t2p_logistic/domain/Model/partner/purchase_inward/update_inward.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart'
    as addresses;
import 'package:t2p_logistic/domain/Model/user/user.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/add_edit_address_screen.dart';
import 'package:t2p_logistic/presentation/screens/address/address_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/address_list.dart';
import 'package:t2p_logistic/presentation/screens/address/map_location_controller.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_controller.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_screen.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_list.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/DeliveryBoyController.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/manage_delivery_boy.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/add_cod.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/financial_log/financial_log.dart';
import 'package:t2p_logistic/presentation/screens/partners/financial_log/financial_log_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/purchase_inward/purchase_inward.dart';
import 'package:t2p_logistic/presentation/screens/partners/purchase_inward/purchase_inward_controller.dart';
import 'package:t2p_logistic/presentation/screens/profile/edit_profile.dart';
import 'package:t2p_logistic/presentation/screens/profile/my_profile.dart';
import 'package:t2p_logistic/presentation/screens/splash/setting_controller.dart';
import 'package:t2p_logistic/presentation/screens/trip/add_trip.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_controller.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_list.dart';
import 'package:t2p_logistic/presentation/theme/theme_light.dart';

import 'duty_test.dart' as fixtures;

class DesignUser extends fixtures.TestUser {
  String role = 'delivery_partner';
  @override
  String get userName => 'Amit Kumar';
  @override
  String get userEmail => 'amit.kumar@example.com';
  @override
  String get userMobile => '9876543210';
  @override
  String get userType => role;
}

class DesignAddresses extends AddressController {
  @override
  Future getAddressList() async {}
  @override
  Future<void> getAllStates() async {}
  @override
  Future<void> getAllCities() async {}
}

class DesignBoys extends DeliveryBoyController {
  @override
  Future getListLogisticBoy({String? lpManagerId}) async {}
}

class DesignFinance extends FinancialLogController {
  @override
  Future financialLog() async {}
}

class DesignPurchases extends PurchaseInwardController {
  @override
  Future getInwardList() async {}
}

class DesignCod extends CodCollectionController {
  @override
  Future getListLogisticBoy() async {}
  @override
  Future getCodExpenseList() async {}
}

class DesignOrders extends OrderController {
  @override
  void getOrders() {
    t2pPickupFilterOrders.assignAll([sampleOrder]);
    t2pDeliveryFilterOrders.assignAll([sampleOrder]);
  }
}

class DesignDuty extends fixtures.TestDuty {
  DesignDuty() : super(fixtures.FakeApi(), fixtures.MemoryStore()) {
    ready = true;
  }
  @override
  Future<void> reconcile({bool silent = false}) async {}
}

final sampleAddress = addresses.Address(
  id: 'address-a',
  title: 'home',
  contactName: 'Amit Kumar',
  contactMobile: '9876543210',
  address: 'Boring Road, Patna',
  address2: 'Near the city centre',
  pincode: '800001',
  state: addresses.State(name: 'Bihar'),
  city: addresses.City(name: 'Patna'),
);
final sampleCod = cod.CodExpense(
  id: 'cod-a',
  number: 'T2P-1790000101',
  amount: '1250',
  active: 0,
  createdDate: '2026-11-01T04:30:00Z',
  city: cod.City(name: 'Patna'),
  addedBy: cod.AddedBy(fullName: 'Amit Kumar'),
);
final sampleOrder = CommonOrder(
  orderId: 'T2P-1790000101',
  id: 'order-a',
  productNames: '1. Lunch Pack',
  createdAt: '01-11-2026 10:00',
  pickupCity: 'Boring Road, Patna',
  deliveryCity: 'Kankarbagh, Patna',
  price: '1250',
  pickupWeight: '5',
  deliveryWeight: '5',
  deliveryZipcode: '800001',
  customerNumber: '9876543210',
  customerAddress: 'Boring Road, Patna, Bihar, 800001',
  express: 'N',
  paymentMode: 'COD',
  deliveryDate: '01-11-2026',
  deliveryTime: '12:00 - 14:00',
  orderStatus: 'PENDING',
  pickupBoy: 'Amit Kumar',
  deliveryBoy: 'Amit Kumar',
  pickupAddress: sampleAddress,
  deliveryAddress: sampleAddress,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_modern_screens_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
    if (const bool.fromEnvironment('MODERN_CAPTURE')) {
      for (final entry in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'materialicons-regular.otf',
      }.entries) {
        final loader = FontLoader(entry.key)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await File(
                  '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/${entry.value}',
                ).readAsBytes(),
              ),
            ),
          );
        await loader.load();
      }
    }
  });
  setUp(() {
    Get.testMode = true;
    Get.put<UserController>(DesignUser());
    Get.put<AddressController>(
      DesignAddresses()..addressList.add(sampleAddress),
    );
    Get.put<DeliveryBoyController>(
      DesignBoys()
        ..boyList.add(
          User(
            id: 'boy-a',
            fullName: 'Amit Kumar',
            mobile: '9876543210',
            email: 'amit@example.com',
            active: 1,
          ),
        ),
    );
    Get.put<FinancialLogController>(
      DesignFinance()
        ..logList.add(
          FinancialLog(
            orderid: 'T2P-1790000101',
            commission: 250,
            distance: '12.34',
            createdDate: '2026-11-01T04:30:00Z',
          ),
        ),
    );
    Get.put<PurchaseInwardController>(
      DesignPurchases()
        ..filterInwardList.add(
          Inward(
            poId: 'PO-1001',
            billNo: 'BILL-101',
            amount: '1250',
            type: 0,
            approved: 1,
            inwardOffice: InwardOffice(name: 'Patna'),
            createdDate: '2026-11-01T04:30:00Z',
          ),
        ),
    );
    // Permanent registrations keep production initState refreshes inside these local fixtures.
    Get.put<CodCollectionController>(
      DesignCod()
        ..filterCodExpenseList.add(sampleCod)
        ..totalExpense.value = '1250',
      permanent: true,
    );
    Get.put<OrderController>(
      DesignOrders()
        ..t2pPickupFilterOrders.add(sampleOrder)
        ..t2pDeliveryFilterOrders.add(sampleOrder),
      permanent: true,
    );
    Get.put<DutyController>(DesignDuty());
    Get.put(AddDeliveryBoyController());
    Get.put(MapLocationController());
    Get.put(TripController());
    Get.put(AuthController());
    Get.put(SettingsController());
  });
  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.reset();
  });

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('MODERN_CAPTURE')) return;
    await tester.runAsync(() async {
      final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('tmp/modern-screens')..createSync(recursive: true);
      await File('${dir.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  final screens = <String, Widget Function()>{
    'profile': () => const MyProfileScreen(),
    'edit-profile': () => const EditProfileScreen(),
    'addresses': () => const AddressListScreen(),
    'add-address': () =>
        const AddEditAddress(isEdit: false, redirectToHome: false),
    'delivery-boys': () => const ManageDeliveryBoy(),
    'add-boy': () => const AddUser(addEditDeliveryBoy: AddEditDeliveryBoy.add),
    'edit-boy': () => AddUser(
      addEditDeliveryBoy: AddEditDeliveryBoy.edit,
      user: Get.find<DeliveryBoyController>().boyList.first,
    ),
    'trips': () => const TripListScreen(),
    'add-trip': () => const AddTripScreen(),
    'financial-logs': () => const FinancialLogs(),
    'purchase-inward': () => const PurchaseInwardList(),
    'edit-inward': () => const UpdateInwardScreen(),
    'cod': () => const CodCollectionScreen(),
    'edit-cod': () => AddCodScreen(expense: sampleCod),
    'orders': () => const OrderList(),
    'login': () => const AuthScreen(),
    'otp': () {
      Get.find<AuthController>().isOTPSent.value = true;
      Get.find<AuthController>().isResendOTP.value = true;
      return const AuthScreen();
    },
  };
  for (final width in [320.0, 390.0]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} fits $width with existing content', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          GetMaterialApp(
            theme: LightTheme.getTheme(),
            home: RepaintBoundary(child: entry.value()),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (width == 390) await capture(tester, entry.key);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  for (final name in [
    'edit-profile',
    'add-address',
    'add-boy',
    'edit-cod',
    'add-trip',
  ]) {
    testWidgets('$name scrolls above the keyboard', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = FakeViewPadding(bottom: 280);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        GetMaterialApp(theme: LightTheme.getTheme(), home: screens[name]!()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('profile Edit navigation preserves the populated form', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LightTheme.getTheme(),
        home: const MyProfileScreen(),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Amit Kumar'), findsWidgets);
    expect(find.text('amit.kumar@example.com'), findsWidgets);
    expect(find.text('9876543210'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('order selection and delivery tab preserve existing behavior', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(theme: LightTheme.getTheme(), home: const OrderList()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select All Orders'));
    await tester.pumpAndSettle();
    expect(Get.find<OrderController>().allOrderSelected(), isTrue);
    await tester.tap(find.text('Deliver(1)'));
    await tester.pumpAndSettle();
    expect(Get.find<OrderController>().orderType.name, 'deliver');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
