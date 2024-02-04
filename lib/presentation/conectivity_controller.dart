import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

class ConnectivityController extends GetxController {
  var isInternetAvailable = true.obs;

  @override
  void onInit() {
    super.onInit();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isInternetAvailable.value = false;
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            'No connection available', CustomSnackBar.error);
      } else {
        if (isInternetAvailable.isFalse) {
          CustomSnackBar.showSnackBar(CustomSnackBar.success,
              'Connection restored', CustomSnackBar.success);
        }
        isInternetAvailable.value = true;
      }
    });
  }
}
