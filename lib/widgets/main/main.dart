import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../navigation/bottom_bar.dart';
import '../navigation/navigation.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      Orientation orientation = MediaQuery.of(context).orientation;

      if (orientation == Orientation.landscape) {
        return Navigation();
      } else {
        return BottomBar();
      }
    });
  }
}
