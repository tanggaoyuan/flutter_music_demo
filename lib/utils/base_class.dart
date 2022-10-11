import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_music/utils/screen_util.dart';
import 'package:flutter_music/utils/http_util.dart' as http;
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:provider/provider.dart';

mixin BaseStateClass<T extends StatefulWidget> on State<T> {
  ScreenUtil? _screenUtil;

  http.HttpUtil get axios => http.axios;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(onLoad);
  }

  void onLoad(Duration time) {
    print('组件渲染成功');
  }

  AudioProvider get audioProvider => context.read<AudioProvider>();

  ScreenUtil get screenUtil {
    return _screenUtil ??= ScreenUtil(context, designWidth: 552);
  }

  double dp(double value) {
    return screenUtil.dp(value);
  }
}

mixin BaseLessStateClass on StatelessWidget {
  ScreenUtil? _screenUtil;

  http.HttpUtil get axios => http.axios;

  AudioPlayer get audio => AudioPlayer();

  ScreenUtil get screenUtil {
    return _screenUtil ??= ScreenUtil.single;
  }

  double dp(double value) {
    return screenUtil.dp(value);
  }
}
