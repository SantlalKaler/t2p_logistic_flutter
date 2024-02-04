import 'package:flutter/material.dart';

Widget getAssetImage(String name, {double? height, double? width}) {
  String base = "assets/images/";
  return Image.asset(
    base + name,
    width: width,
    height: height,
  );
}

ImageProvider getAssetImageProvider(
  String name,
) {
  String base = "assets/images/";
  return AssetImage(base + name);
}

Image getNetworkImage(String image, {double? width, double? height}) {
  return Image.network(
    image,
    width: width,
    height: height,
  );
}
