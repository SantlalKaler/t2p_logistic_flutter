import 'package:flutter/material.dart';

class DefaultDialog extends StatefulWidget {
  final Widget? icon;
  final String? title;
  final String? message;
  final String? btn1Txt;
  final VoidCallback btn1Click;
  final String? btn2Txt;
  final VoidCallback? btn2Click;

  const DefaultDialog(
      {super.key,
      this.icon,
      this.title,
      this.message,
      this.btn1Txt,
      required this.btn1Click,
      this.btn2Txt,
      this.btn2Click});

  @override
  State<DefaultDialog> createState() => _DefaultDialogState();
}

class _DefaultDialogState extends State<DefaultDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: widget.icon,
      title: Text(widget.message ?? ""),
      //content: Text(widget.message ?? ""),
      actions: [
        ElevatedButton(
            onPressed: widget.btn1Click, child: Text(widget.btn1Txt ?? "Ok")),
        if (widget.btn2Txt != null)
          OutlinedButton(
              onPressed: widget.btn2Click!,
              child: Text(widget.btn2Txt!)),
      ],
    );
  }
}
