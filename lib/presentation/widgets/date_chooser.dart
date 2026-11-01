import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';

dateChooser(BuildContext context) {
  return Container(
    color: Theme.of(context).primaryColor,
    padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
    child: Column(
      children: [
        const Text(
          "Choose date range to filter order list",
          style: TextStyle(color: Colors.white),
        ),
        Gap(DimensConstants.spaceBetweenViewsAndSubViews),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            datePickerView("Start Date"),
            Gap(DimensConstants.spaceBetweenViewsAndSubViews),
            datePickerView("End Date"),
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: const Text(
            "Submit",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

datePickerView(String text, {bool showIcon = true}) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon)
            const Icon(
              Icons.calendar_month,
              color: Color(0xFFB42332),
              size: 18,
            ),
          Gap(DimensConstants.spaceBetweenViews),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF182230),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
