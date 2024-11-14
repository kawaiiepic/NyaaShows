import 'dart:developer';

import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

class Discord {
  static String client_id = '1287141763357868052';

  int startEpoch = DateTime.now().millisecondsSinceEpoch;

  static init() async {
    try {
      await FlutterDiscordRPC.initialize(
      client_id,
    );

    await FlutterDiscordRPC.instance.connect();
    } catch (e) {
      log(e.toString());
    }
  }

  static resetPresence() {
    FlutterDiscordRPC.instance.clearActivity();
  }

  static updatePresence(RPCActivity activity) {
    if (FlutterDiscordRPC.instance.isConnected) {
      FlutterDiscordRPC.instance.setActivity(activity: activity);
    }
  }
}
