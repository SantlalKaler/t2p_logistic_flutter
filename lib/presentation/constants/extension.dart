import 'package:intl/intl.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';

extension DateFormatExtension on String {
  String toDate({String outputDate = "dd-MM-yyyy"}) {
    try {
      DateTime inputDate = DateTime.parse(this);
      return DateFormat(outputDate).format(inputDate);
    } catch (e) {
      printValue("Error in converting : $e");
      return this;
    }
  }
}
