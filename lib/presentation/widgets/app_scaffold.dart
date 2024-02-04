import 'package:flutter/material.dart';
import 'package:t2p_logistic/presentation/theme/resource/color_constant.dart';

appScaffold(AppBar? appBar, Widget body,)  {
  return Scaffold(
    backgroundColor: ColorConstants.screenBackgroundColor,
    appBar: appBar,
    body: body,
  );
}

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  const AppScaffold({super.key, this.body, this.appBar, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: ColorConstants.screenBackgroundColor,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

