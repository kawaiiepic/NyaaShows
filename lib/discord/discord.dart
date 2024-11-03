import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

class Discord {
  String client_id = '1287141763357868052';

  int startEpoch = DateTime.now().millisecondsSinceEpoch;

  init() async {
    await FlutterDiscordRPC.initialize(
      client_id,
    );
    FlutterDiscordRPC.instance.connect();
  }

  resetPresence() {
    FlutterDiscordRPC.instance.clearActivity();
  }

  updatePresence(RPCActivity activity) {
    FlutterDiscordRPC.instance.setActivity(activity: activity);
  }
}
