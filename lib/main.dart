import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nyaashows/data/data_manager.dart';
import 'package:nyaashows/locale_fix.dart';
import 'trakt.dart';
import 'widgets/scaffold.dart' as scaffold;

class NyaaShows {
  static TraktModel traktModel = TraktModel();
  static DataManager dataManager = DataManager();
  static RealDebridAPI realDebrid = RealDebridAPI();
}

void main() async {
  setNumericLocaleToC();
  WidgetsFlutterBinding.ensureInitialized();
  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  runApp(const MyApp());

  NyaaShows.dataManager.checkData();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NyaaShows',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NyaaShows'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => scaffold.MyHomePageState();
}

enum Menu { settings, trakt, about, realdebrid }
