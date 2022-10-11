import 'package:flutter/material.dart';
import 'package:flutter_music/pages/music_audio_page/music_audio_page.dart';
import 'package:flutter_music/pages/not_page/not_page.dart';
import 'package:flutter_music/pages/music_list/music_list.dart';

class RouterUtil {
  static String initialRoute = '/';

  static BuildContext? context;

  static final Map<String, Widget Function({dynamic arguments})> routerViewMap =
      {
    "/not": ({arguments}) => const Not(),
    "/audio": ({arguments}) => MusicAudioPage(arguments: arguments),
    "/home": ({arguments}) => MusicList()
  };

  static Route<Widget> buildRouterView(RouteSettings setting) {
    return MaterialPageRoute(builder: (context) {
      RouterUtil.context = context;
      var build = routerViewMap[setting.name];
      if (build == null) {
        return const Not();
      }
      return build(arguments: setting.arguments);
    });
  }
}
