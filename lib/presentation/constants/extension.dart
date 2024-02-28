import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';

extension DateFormatExtension on String {//7985398008
  String toDate({String outputDate = "dd-MM-yyyy"}) {
    try {
      DateTime utcDateTime  = DateTime.parse(this);
      DateTime istDateTime = utcDateTime.add(const Duration(hours: 5, minutes: 30));
      String formattedIST = DateFormat(outputDate).format(istDateTime);

      /*printValue(
          "Input date : $this\nOutput date : $formattedIST");*/

      return formattedIST;
    } catch (e) {
      //printValue("Error in converting Date: $e");
      return this;
    }
  }
}

extension StringExtension on String? {
  String toFixString() {
    try {
      return double.parse(this ?? "0.0").toStringAsFixed(2);
    } catch (e) {
      printValue("Error in converting : $e\nHas to convert $this");
      return this ?? "0.0";
    }
  }
}
