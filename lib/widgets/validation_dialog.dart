import 'package:flutter/material.dart';

class ValidationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String textButton;
  final VoidCallback? onButtonPressed;

  const ValidationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.textButton,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(textButton),
          onPressed: () {
            if (onButtonPressed != null) {
              onButtonPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          //onPressed: () {
          //  Navigator.of(context).pop();
          //},
        ),
      ],
    );
  }

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return this;
      },
    );
  }
}
