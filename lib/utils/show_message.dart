
import 'package:flutter/material.dart';

showMessage({String message = "Something wrong", Duration duration = const Duration(seconds: 3),required BuildContext myContext,bool error = false,int top = 230}) {
  ScaffoldMessenger.of(myContext).showSnackBar(
    SnackBar(
      duration: duration,
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          letterSpacing: 0.4, color: Colors.white,
        ),
      ),
      backgroundColor: error ? Colors.red: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(myContext).size.height - top,
          right: 20,
          left: 20,
      ),
    ),
  );
}
