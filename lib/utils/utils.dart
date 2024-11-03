import 'package:flutter/material.dart';

class Utils {
  static Widget loading() {
    return const Center(
        child: SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(),
    ));
  }

  static Widget error() {
    return const Center(
        child: Icon(
      Icons.error_outline,
      color: Colors.red,
      size: 60,
    ));
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
