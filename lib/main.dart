import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'dart:developer' as developer;

import 'discord/discord.dart';
import 'real-debrid/real_debrid.dart';
import 'widgets/main/main.dart';

class NyaaShows {
  static RealDebrid realDebrid = RealDebrid();

  static void log(String message) {
    developer.log(message);
  }
}

void main() async {
  Discord.init();
  VideoPlayerMediaKit.ensureInitialized(
    android: true, // default: false    -    dependency: media_kit_libs_android_video
    iOS: true, // default: false    -    dependency: media_kit_libs_ios_video
    macOS: true, // default: false    -    dependency: media_kit_libs_macos_video
    windows: true, // default: false    -    dependency: media_kit_libs_windows_video
    linux: true, // default: false    -    dependency: media_kit_libs_linux
  );
  runApp(NyaaApp());
  // TraktJson.userProfile();
}

class NyaaApp extends StatefulWidget {
  const NyaaApp({super.key});

  @override
  State<NyaaApp> createState() => _NyaaAppState();
}

class _NyaaAppState extends State<NyaaApp> {
  ThemeMode? themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final materialLightTheme = ThemeData.light();
    final materialDarkTheme = ThemeData(brightness: Brightness.dark, platform: defaultTargetPlatform
        /* dark theme settings */
        );

    const darkDefaultCupertinoTheme = CupertinoThemeData(brightness: Brightness.dark);
    final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
      materialTheme: materialDarkTheme.copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
          textTheme: CupertinoTextThemeData(
            primaryColor: Colors.white,
            navActionTextStyle: darkDefaultCupertinoTheme.textTheme.navActionTextStyle.copyWith(
              color: const Color(0xF0F9F9F9),
            ),
            navLargeTitleTextStyle: darkDefaultCupertinoTheme.textTheme.navLargeTitleTextStyle.copyWith(color: const Color(0xF0F9F9F9)),
          ),
        ),
      ),
    );
    final cupertinoLightTheme = MaterialBasedCupertinoThemeData(materialTheme: materialLightTheme);

    return PlatformProvider(
      initialPlatform: TargetPlatform.linux,
      settings: PlatformSettingsData(
        iosUsesMaterialWidgets: true,
        iosUseZeroPaddingForAppbarPlatformIcon: true,
      ),
      builder: (context) => PlatformTheme(
        themeMode: themeMode,
        materialLightTheme: materialLightTheme,
        materialDarkTheme: materialDarkTheme,
        cupertinoLightTheme: cupertinoLightTheme,
        cupertinoDarkTheme: cupertinoDarkTheme,
        matchCupertinoSystemChromeBrightness: true,
        onThemeModeChanged: (themeMode) {
          this.themeMode = themeMode; /* you can save to storage */
        },
        builder: (context) => PlatformApp(localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ], title: 'NyaaShows', home: Home()),
      ),
      // ),
    );
  }
}
