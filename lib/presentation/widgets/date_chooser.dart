import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';

dateChooser(
  BuildContext context,
) {
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
            datePickerView("End Date")
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
        )
      ],
    ),
  );
}

datePickerView(String text, {bool showIcon = true}) {
  return Expanded(
    child: Container(
      color: Colors.white,
      padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon)
            const Icon(
              Icons.calendar_month,
              color: Colors.red,
            ),
          Gap(DimensConstants.spaceBetweenViews),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    ),
  );
}
