import 'package:flutter/widgets.dart';

const double defaultDesignWidth = 1080.00;

class ScreenUtil {
  late double _designWidth;

  late MediaQueryData _mediaQuery;

  ScreenUtil.create({
    required BuildContext context,
    double? designWidth,
  }) {
    _designWidth = designWidth ?? defaultDesignWidth;
    _mediaQuery = MediaQuery.of(context);
  }

  static ScreenUtil? _ins;

  factory ScreenUtil(BuildContext context, {double? designWidth}) {
    return ScreenUtil._ins ??=
        ScreenUtil.create(context: context, designWidth: designWidth);
  }

  static ScreenUtil get single {
    return ScreenUtil._ins as ScreenUtil;
  }

  double dp(double value) {
    return value * scaleWidth;
  }

  double fontDp(double value) {
    return dp(value) / textScaleFactor;
  }

  double get sreenWidth {
    return _mediaQuery.size.width;
  }

  double get sreenHeight {
    return _mediaQuery.size.height;
  }

  double get topBarHeight {
    return _mediaQuery.padding.top;
  }

  double get textScaleFactor {
    return _mediaQuery.textScaleFactor;
  }

  double get scaleWidth => sreenWidth / _designWidth;
}
