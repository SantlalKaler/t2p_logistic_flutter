import 'package:flutter/cupertino.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:url_launcher/url_launcher.dart';

removeFocus(BuildContext context) {
  FocusScope.of(context).unfocus();
}

openUrl(String url) async {
  printValue("Url : $url");
  if (await launchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not open the map.';
  }
}
