import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/theme.dart';
import 'models/data.dart';
import 'models/data_all.dart';
import 'models/entry_style.dart';
import 'models/nav.dart';
import 'models/settings.dart';
import 'models/theme_settings.dart';
import 'screens/home.dart';
import 'screens/category.dart';
import 'screens/entry.dart';
import 'screens/feed.dart';
import 'screens/feed_create.dart';
import 'screens/feeds.dart';
import 'screens/search.dart';
import 'screens/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeSettings = await ThemeSettings.createAndLoad();

  runApp(MyApp(themeSettings));
}

class MyApp extends StatelessWidget {
  final ThemeSettings themeSettings;

  const MyApp(this.themeSettings, { Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Data()),
        ChangeNotifierProvider(create: (context) => DataAll()),
        ChangeNotifierProvider(create: (context) => EntryStyle()),
        ChangeNotifierProvider(create: (context) => Nav()),
        ChangeNotifierProvider(create: (context) => Settings()),
        ChangeNotifierProvider(create: (context) => themeSettings)
      ],
      child: AnimatedBuilder(
        animation: themeSettings,
        builder: (context, child) => MaterialApp(
            title: 'Miniflutt',
            theme: appTheme,
            darkTheme: appThemeDark,
            themeMode: themeSettings.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => MyHome(),
              '/category': (context) => MyCategory(),
              '/entry': (context) => MyEntry(),
              '/feed': (context) => MyFeed(),
              '/feed_create': (context) => MyFeedCreate(),
              '/feeds': (context) => MyFeeds(),
              '/search': (context) => MySearch(),
              '/settings': (context) => MySettings(),
            },
          ),
      ),
    );
  }
}
