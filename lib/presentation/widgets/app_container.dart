import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';

appContainer(Widget child, {double? height, double width = double.infinity}) {
  return Container(
   // height: height,
      width: width,
    padding: EdgeInsets.all(DimensConstants.cardInnerPadding),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Colors.white),
    child: child,
  );
}
