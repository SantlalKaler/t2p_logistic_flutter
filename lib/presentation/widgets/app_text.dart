import 'package:flutter/material.dart';

class AppHeading2Text extends StatefulWidget {
  final String text;

  const AppHeading2Text({super.key, required this.text});

  @override
  State<AppHeading2Text> createState() => _AppHeading2TextState();
}

class _AppHeading2TextState extends State<AppHeading2Text> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    );
  }
}

class AppNormalText extends StatefulWidget {
  final String text;

  const AppNormalText({super.key, required this.text});

  @override
  State<AppNormalText> createState() => _AppNormalTextState();
}

class _AppNormalTextState extends State<AppNormalText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      textAlign: TextAlign.start,
    );
  }
}


