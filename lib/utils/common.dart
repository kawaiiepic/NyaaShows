import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:path_provider/path_provider.dart';

class Common {
  static Widget loading() {
    return Center(
        child: SizedBox(
      width: 60,
      height: 60,
      child: PlatformCircularProgressIndicator(),
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

  static Future<File> dirJson(String name) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$name.json');
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }
}



extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
