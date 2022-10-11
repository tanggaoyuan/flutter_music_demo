import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:flutter_music/utils/router.dart';
import 'package:flutter_music/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  Provider.debugCheckInvalidValueType = null;
  runApp(
    ChangeNotifierProvider.value(
      value: AudioProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '网易云音乐',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // scaffoldBackgroundColor: value.bodyColor,
        // textTheme:
        //     const TextTheme(bodyText2: TextStyle(color: Colors.white))
      ),
      initialRoute: '/home',
      onGenerateRoute: RouterUtil.buildRouterView,
    );
  }
}
