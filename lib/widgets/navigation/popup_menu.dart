import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nyaashows/trakt/trakt_json.dart';

import '../../real-debrid/real_debrid.dart';

class PopupMenu extends StatelessWidget {
  const PopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformPopupMenu(
        options: [
          PopupMenuOption(
              onTap: (p0) {
                TraktJson.auth(context);
              },
              label: 'Connect Trakt'),
          PopupMenuOption(
              onTap: (p0) {
                RealDebrid.login(context);
              },
              label: 'Connect Real-Debrid'),
             PopupMenuOption(
              onTap: (p0) {
                TraktJson.auth(context);
              },
              label: 'Refresh App'),
        ],
        icon: FutureBuilder(
          future: TraktJson.userProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CircleAvatar(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(snapshot.data!.images.avatar.full),
                ),
              );
            } else {
              return Icon(Icons.person);
            }
          },
        ));
  }
}
