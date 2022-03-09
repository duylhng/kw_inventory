import 'package:flutter/material.dart';

import '../globals/globals.dart';

void showCustomSnackBar(String text, {int? duration, bool? error}) {
  final SnackBar snackBar = SnackBar(
    backgroundColor: error != null ?
    error ? Colors.red : Colors.black87
        : Colors.black87,
    content: Text(
      text,
      style: const TextStyle(
          color: Colors.white
      ),
    ),
    elevation: 5.0,
    duration: Duration(seconds: duration ?? 4),
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(7))
    ),
  );

  snackBarKey.currentState?.showSnackBar(snackBar);
}