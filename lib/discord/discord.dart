import 'package:discord_rpc/discord_rpc.dart';

class Discord {
  DiscordRPC rpc = DiscordRPC(
    applicationId: '1287141763357868052',
  );

  int startEpoch = DateTime.now().millisecondsSinceEpoch;

  start() {
    rpc.start(autoRegister: true);
    resetPresence();
  }

  resetPresence() {
    rpc.updatePresence(
      DiscordPresence(
          state: 'Browsing 📺',
          startTimeStamp: startEpoch,
          largeImageKey: 'https://i.pinimg.com/736x/7d/49/4e/7d494e29437e63f67c910253ab002436.jpg',
          smallImageKey: 'https://static-00.iconduck.com/assets.00/trakt-icon-2048x2048-2633ksxg.png',
          smallImageText: 'Powered by Trakt'
          ),
    );
  }

  updatePresence(DiscordPresence discordPresence) {
    rpc.updatePresence(discordPresence);
  }
}
