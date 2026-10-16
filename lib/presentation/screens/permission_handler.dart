import 'package:permission_handler/permission_handler.dart';

Future<bool> isPermissionGranted(Permission permission) async {
  final status = await permission.status;
  if (status.isGranted) return true;
  // On Android, permanent denial is reliable on the request result,
  // rather than on a subsequent status query (permission_handler 13).
  final result = await permission.request();
  return result.isGranted;
}
