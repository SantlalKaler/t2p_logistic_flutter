import 'package:flutter/material.dart';

import '../../../theme/resource/dimens.dart';

class SingleOrderInfoItem extends StatelessWidget {
  final String? title;
  final Color? color;
  final double? height;
  final double? width;

  const SingleOrderInfoItem({
    super.key,
    this.color,
    this.title,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: height ?? 9,
          width: width ?? 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? const Color(0xFFB42332),
          ),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              left: DimensConstants.spaceBetweenViewsAndSubViews,
            ),
            child: Text(
              title ?? "",
              maxLines: 20,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
