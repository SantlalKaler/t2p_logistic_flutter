import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';
import 'package:t2p_logistic/domain/Model/user/office_data.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/getstorage_keys_constants.dart';

import '../../domain/Model/user/user.dart';
import '../screens/auth/auth_screen.dart';
import '../theme/resource/custom_constants.dart';

class UserController extends GetxController {
  final box = GetStorage();

  //user info
  String get userId => box.read(GetStorageKeys.userId);

  bool get isLoggedIn => box.read(GetStorageKeys.isLoggedIn) ?? false;

  String get userName => box.read(GetStorageKeys.userName);

  String get userEmail => box.read(GetStorageKeys.userEmail);

  String get userMobile => box.read(GetStorageKeys.userMobile);

  String get userType => box.read(GetStorageKeys.userType);

  String get officeId => box.read(GetStorageKeys.officeId);

  String get userCity => box.read(GetStorageKeys.userCity);

  //order info
  String? get orderId => box.read(GetStorageKeys.orderId);

  double? get deliveryLat => box.read(GetStorageKeys.deliveryLat);

  bool get orderAlreadyStarted =>
      box.read(GetStorageKeys.orderAlreadyStarted) ?? false;

  double? get deliveryLng => box.read(GetStorageKeys.deliveryLng);

  double? get pickupLat => box.read(GetStorageKeys.pickupLat);

  String? get orderPrice => box.read(GetStorageKeys.orderPrice);

  String? get orderCustomerMobile =>
      box.read(GetStorageKeys.orderCustomerMobile);

  double? get pickupLng => box.read(GetStorageKeys.pickupLng);

  double? get orderType => box.read(GetStorageKeys.orderType);

  double? get t2pOrderType => box.read(GetStorageKeys.t2pOrderType);

  String? get paymentMode => box.read(GetStorageKeys.paymentMode);

  // CommonOrder? get savedOrder => box.read(GetStorageKeys.startedOrder);

  saveUser(User user, OfficeData? officeData) {
    final Map<String, dynamic> userMap = {
      GetStorageKeys.isLoggedIn: true,
      GetStorageKeys.userId: user.id,
      GetStorageKeys.userName: user.fullName,
      GetStorageKeys.userMobile: user.mobile,
      GetStorageKeys.userEmail: user.email,
      GetStorageKeys.userType: user.userType,
      GetStorageKeys.officeId: officeData?.id ?? "",
      GetStorageKeys.userCity: (user.customerSupportCity!.isNotEmpty &&
              user.customerSupportCity != null)
          ? user.customerSupportCity![0].toString()
          : ""
    };

    userMap.forEach((key, value) {
      box.write(key, value);
    });

    printValue("$userType\n$userId\n$officeId");
  }

  saveStartedOrderInfo(CommonOrder? order, Position position,
      T2POrderType t2pOrderType, OrderType orderType) {
    final Map<String, dynamic> orderMpa = {
      GetStorageKeys.orderAlreadyStarted: true,
      GetStorageKeys.deliveryLat:
          order?.deliveryAddress?.position?.coordinates?[0],
      GetStorageKeys.deliveryLng:
          order?.deliveryAddress?.position?.coordinates?[1],
      GetStorageKeys.pickupLat: position.latitude,
      GetStorageKeys.pickupLng: position.longitude,
      GetStorageKeys.orderId: order!.id!,
      GetStorageKeys.paymentMode: order.paymentMode!,
      GetStorageKeys.orderPrice:
          t2pOrderType == T2POrderType.AF2AP ? order.duesAmount : order.price!,
      GetStorageKeys.orderCustomerMobile: order.customerNumber!,
      GetStorageKeys.t2pOrderType: t2pOrderType.name,
      GetStorageKeys.orderType: orderType.name,
    };

    orderMpa.forEach((key, value) {
      box.write(key, value);
    });
  }

  //clear info that we save when delivery boy start his order
  clearOrderInfo() {
    box.write(GetStorageKeys.orderAlreadyStarted, false);
    box.remove(GetStorageKeys.orderId);
    box.remove(GetStorageKeys.deliveryLat);
    box.remove(GetStorageKeys.deliveryLng);
    box.remove(GetStorageKeys.pickupLat);
    box.remove(GetStorageKeys.pickupLng);
    box.remove(GetStorageKeys.paymentMode);
    box.remove(GetStorageKeys.orderPrice);
    box.remove(GetStorageKeys.orderCustomerMobile);
    box.remove(GetStorageKeys.t2pOrderType);
    box.remove(GetStorageKeys.orderType);
  }

  getSavedUserInfo() {
    printValue(
        "User Id : $userId\nUser Type : $userType\nUser Name : $userName\n");
  }

  clearUser() {
    box.remove(GetStorageKeys.userId);
    box.remove(GetStorageKeys.userName);
    box.remove(GetStorageKeys.userEmail);
    box.remove(GetStorageKeys.userMobile);
    box.remove(GetStorageKeys.userType);
    box.remove(GetStorageKeys.officeId);
    box.write(GetStorageKeys.isLoggedIn, false);

    box.write(GetStorageKeys.orderAlreadyStarted, false);
    box.remove(GetStorageKeys.orderId);
    box.remove(GetStorageKeys.deliveryLat);
    box.remove(GetStorageKeys.deliveryLng);
    box.remove(GetStorageKeys.pickupLat);
    box.remove(GetStorageKeys.pickupLng);
    box.remove(GetStorageKeys.paymentMode);
    box.remove(GetStorageKeys.orderPrice);
    box.remove(GetStorageKeys.orderCustomerMobile);
    box.remove(GetStorageKeys.t2pOrderType);
    box.remove(GetStorageKeys.orderType);

    AuthController controller = Get.find();
    controller.isOTPSent.value = false;
    Get.offAll(() => const AuthScreen());
  }
}
