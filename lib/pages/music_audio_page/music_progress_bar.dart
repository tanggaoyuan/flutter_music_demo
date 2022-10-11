import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_music/utils/base_class.dart';

String formTime(Duration duration) {
  String hours = duration.inHours.toString().padLeft(0, '2');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "${hours == '0' ? '' : hours + ':'}$minutes:$seconds";
}

class MusicProgressBar extends StatefulWidget {
  MusicProgressBarController controller;
  Function(int time) onChange;
  MusicProgressBar({Key? key, required this.controller, required this.onChange})
      : super(key: key);
  @override
  State<MusicProgressBar> createState() => _MusicProgressBarState();
}

class _MusicProgressBarState extends State<MusicProgressBar>
    with BaseStateClass {
  final GlobalKey globalKey = GlobalKey();
  int _current = 0;
  int _duration = 0;
  bool _flag = false;

  void update() {
    if (_flag) {
      return;
    }
    setState(() {
      _current = widget.controller.current;
      _duration = widget.controller.duration;
    });
  }

  @override
  void initState() {
    update();
    widget.controller.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);
    super.dispose();
  }

  void stopDrag() {
    _flag = false;
    widget.controller.updateCurrent(_current);
    widget.onChange(_current);
  }

  void dragProgress(double x) {
    _flag = true;
    var width = globalKey.currentContext?.size?.width;
    if (width != null) {
      double rb = x / width;
      rb = rb > 1 ? 1 : (rb < 0 ? 0 : rb);
      int time = (rb * widget.controller.duration).toInt();
      setState(() {
        _current = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthFactor = _current / _duration;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dp(42)),
      child: Row(
        children: [
          Text(
            formTime(Duration(milliseconds: _current)),
            style: TextStyle(color: Colors.white70, fontSize: dp(14)),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: dp(10)),
              child: GestureDetector(
                key: globalKey,
                onHorizontalDragDown: (e) {
                  dragProgress(e.localPosition.dx);
                },
                onHorizontalDragUpdate: (e) {
                  dragProgress(e.localPosition.dx);
                },
                onHorizontalDragEnd: (_) {
                  stopDrag();
                },
                onHorizontalDragCancel: stopDrag,
                child: Container(
                  height: dp(14),
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.loose,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: dp(1),
                        width: double.infinity,
                        color: Colors.white24,
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          top: dp(-5),
                          height: dp(10),
                          child: Row(
                            children: [
                              Flexible(
                                  child: FractionallySizedBox(
                                widthFactor: widthFactor.isNaN
                                    ? 0.001
                                    : (widthFactor > 1 ? 1 : widthFactor),
                                child: Container(
                                  color: Colors.white,
                                  height: dp(1),
                                ),
                              )),
                              Container(
                                height: dp(10),
                                width: dp(10),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                              )
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(
            formTime(Duration(milliseconds: _duration)),
            style: TextStyle(color: Colors.white70, fontSize: dp(14)),
          ),
        ],
      ),
    );
  }
}

class MusicProgressBarController extends ChangeNotifier {
  int current = 0;
  int duration = 0;
  MusicProgressBarController();

  void updateCurrent(int value) {
    if (value == current) {
      return;
    }
    current = value;
    notifyListeners();
  }

  void updateDuration(int value) {
    if (value == duration) {
      return;
    }
    duration = value;
    notifyListeners();
  }
}
