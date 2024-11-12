import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

class Discord {
  static String client_id = '1287141763357868052';

  int startEpoch = DateTime.now().millisecondsSinceEpoch;

  static init() async {
    await FlutterDiscordRPC.initialize(
      client_id,
    );
    FlutterDiscordRPC.instance.connect();
  }

  static resetPresence() {
    FlutterDiscordRPC.instance.clearActivity();
  }

  static updatePresence(RPCActivity activity) {
    if (FlutterDiscordRPC.instance.isConnected) {
      print(FlutterDiscordRPC.instance.isConnected);
      FlutterDiscordRPC.instance.setActivity(activity: activity);
    }
  }
}
