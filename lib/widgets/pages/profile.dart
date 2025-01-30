import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../navigation/popup_menu.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [PopupMenu()],
    );
  }
}
