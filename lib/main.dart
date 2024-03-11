import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:music/providers/identify_controller.dart';
import 'package:music/providers/mark_songs.dart';
import 'package:music/providers/playList_database.dart';
import 'package:music/providers/song_controller.dart';
import 'package:music/screens/library.dart';
import 'package:music/util/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:music/screens/splash.dart';

import 'providers/all_songs.dart';
import 'screens/playList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioSession.instance.then((session) {
    session.configure(AudioSessionConfiguration.music());
    SharedPreferences.getInstance().then((pref) {
      int theme = pref.getInt('theme') ?? 0;
      runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ProviderClass(themeData: kThemes[theme])),
          ChangeNotifierProvider(create: (_) => PlayListDB()),
          ChangeNotifierProvider(create: (_) => SongController()),
          ChangeNotifierProvider(create: (_) => MarkSongs()),
          ChangeNotifierProvider(create: (_) => IdentifyController()),
        ],
        child: MyApp(theme: kThemes[theme]),
      ));
    });
  });
  //
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required theme});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: Provider.of<ProviderClass>(context).theme,
      home: SplashScreen(theme: ThemeData.light()),
      routes: {
        Library.pageId: (ctx) => Library(),
        PlayList.pageId: (ctx) => PlayList(),
      },
    );
  }
}
