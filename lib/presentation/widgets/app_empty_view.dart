import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';

class AppEmptyView extends StatefulWidget {
  final String? message;

  const AppEmptyView({super.key, this.message});

  @override
  State<AppEmptyView> createState() => _AppEmptyViewState();
}

class _AppEmptyViewState extends State<AppEmptyView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              color: Theme.of(context).primaryColor,
            ),
            Gap(DimensConstants.spaceBetweenViews),
            Text(
              widget.message ?? "",
              style: const TextStyle(fontSize: 16),
            )
          ],
        ))
      ],
    );
  }
}
