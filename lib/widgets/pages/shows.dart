import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../search/search.dart';

class Shows extends StatefulWidget {
  const Shows({super.key});

  @override
  State<StatefulWidget> createState() => _ShowsState();
}

class _ShowsState extends State<Shows> {
  List<Widget> showsWidget = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        Center(child: Search()),
        Text('Dashboard'),

      ],
    ));
  }
}
