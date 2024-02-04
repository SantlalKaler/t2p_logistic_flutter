import 'package:flutter/material.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';

import 'app_back_button.dart';

appBar(
    {String? title,
    Widget? leading,
    bool centerTitle = false,
    List<Widget> actions = const []}) {
  return AppBar(
    elevation: 0,
    title: Text(title ?? StringConstants.appName),
    actions: actions,
    leading: leading,
    centerTitle: centerTitle,
  );
}

class AppBarSliver extends StatelessWidget {
  final String? title;
  Widget? leading = const AppBackButton();
  List<Widget>? actions = [];
  PreferredSizeWidget? bottom;

  AppBarSliver({super.key, this.title, this.leading,this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      leading: leading,
      title: Text(title ?? ""),
      actions: actions,
      bottom: bottom,
    );
  }
}

class AppBarNormal extends StatelessWidget {
  final String? title;
  Widget? leading = const AppBackButton();
  List<Widget>? actions = [];

  AppBarNormal({super.key, this.title, this.leading,this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(title ?? ""),
      actions: actions,
    );
  }
}
