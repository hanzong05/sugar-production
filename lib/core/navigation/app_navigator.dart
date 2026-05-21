import 'package:flutter/material.dart';

class AppNavigator {
  static Future push(BuildContext context, Widget page) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static Future pushReplace(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
