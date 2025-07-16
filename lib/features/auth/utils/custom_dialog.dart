import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onOk;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onOk != null) {
              onOk!();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  VoidCallback? onOk,
}) {
  showDialog(
    context: context,
    builder: (_) => CustomDialog(
      title: title,
      message: message,
      onOk: onOk,
    ),
  );
}
