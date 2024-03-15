import 'package:flutter/material.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';

showDatePickerDialog(BuildContext context,Function pickedDate) async {
  final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020, 10),
      lastDate: DateTime.now());
  if (picked != null) {
    var date = picked.toString().toDate();
    pickedDate(date);
  }
}