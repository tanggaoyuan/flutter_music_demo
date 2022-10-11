import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music/models/song_item_model.dart';
import 'package:flutter_music/pages/music_audio_page/music_progress_bar.dart';
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:flutter_music/utils/base_class.dart';
import 'package:provider/provider.dart';

class MusicAudioPage extends StatefulWidget {
  SongItemModel arguments;
  MusicAudioPage({Key? key, required this.arguments}) : super(key: key);

  @override
  State<MusicAudioPage> createState() => _MusicAudioPageState();
}

class _MusicAudioPageState extends State<MusicAudioPage>
    with SingleTickerProviderStateMixin, BaseStateClass {
  late AnimationController _coverRotateController;

  void init() {
    _coverRotateController.duration = Duration.zero;
    _coverRotateController.animateTo(audioProvider.rotate);
    _coverRotateController.duration = const Duration(seconds: 18);
    if (audioProvider.isPlay) {
      _coverRotateController.repeat();
    } else {
      _coverRotateController.stop();
    }
    if (audioProvider.isPlay) {
      _coverRotateController.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    audioProvider.play(widget.arguments);
    _coverRotateController = AnimationController(vsync: this);
    init();
    audioProvider.addListener(init);
    _coverRotateController.addListener(() {
      audioProvider.rotate = _coverRotateController.value;
    });
  }

  @override
  void dispose() {
    _coverRotateController.dispose();
    audioProvider.removeListener(init);
    super.dispose();
  }

  Widget renderScaffold() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(dp(24)),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  renderHeader(),
                  renderBody(),
                  renderActions(),
                  renderIndicator(),
                  renderPlayAction(),
                  SizedBox(
                    height: dp(10),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
        builder: (context, value, child) {
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(value.currentSong!.cover),
                      fit: BoxFit.cover)),
              child: child);
        },
        child: Stack(
          children: [
            ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 34.0, sigmaY: 34.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Container(color: Colors.black),
                  )),
            ),
            renderScaffold()
          ],
        ));
  }

  Widget renderPlayAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            audioProvider.up();
          },
          child: Transform.rotate(
            angle: -pi,
            child: Image.asset(
              'images/dl6.png',
              width: dp(70),
            ),
          ),
        ),
        SizedBox(width: dp(40)),
        GestureDetector(
          onTap: () {
            if (audioProvider.isPlay) {
              audioProvider.audio.pause();
            } else {
              audioProvider.play(audioProvider.currentSong as SongItemModel);
            }
          },
          child: Consumer<AudioProvider>(
            builder: (context, value, _) {
              return Image.asset(
                value.isPlay ? 'images/c7p.png' : 'images/c7k.png',
                width: dp(75),
              );
            },
          ),
        ),
        SizedBox(width: dp(40)),
        GestureDetector(
          onTap: () {
            audioProvider.next();
          },
          child: Image.asset(
            'images/dl6.png',
            width: dp(70),
          ),
        )
      ],
    );
  }

  Widget renderIndicator() {
    return MusicProgressBar(
      controller: audioProvider.musicProgressBarController,
      onChange: (value) {
        audioProvider.audio.seek(Duration(milliseconds: value));
      },
    );
  }

  Widget renderHeader() {
    return SizedBox(
      height: dp(80),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(
              'images/cp5.png',
              width: dp(38),
              height: dp(38),
            ),
          ),
          SizedBox(
            width: dp(38),
          ),
          Flexible(child: Consumer<AudioProvider>(builder: (_, value, __) {
            return Column(
              children: [
                Text(
                  value.currentSong!.name,
                  style: TextStyle(
                      fontSize: dp(26),
                      color: Colors.white,
                      height: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  value.currentSong!.artist,
                  style: TextStyle(
                      fontSize: dp(20),
                      color: Colors.white60,
                      overflow: TextOverflow.ellipsis),
                )
              ],
            );
          })),
          SizedBox(
            width: dp(76),
          )
        ],
      ),
    );
  }

  Widget renderBody() {
    return Expanded(
      flex: 1,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: dp(90)),
            child: Image.asset(
              'images/disk.png',
              width: dp(410),
              height: dp(410),
            ),
          ),
          Positioned(
              top: dp(166),
              left: dp(76),
              child: RotationTransition(
                turns: _coverRotateController,
                child: ClipOval(
                  child: Consumer<AudioProvider>(
                    builder: (context, value, _) {
                      return Image.network(
                        value.currentSong!.cover,
                        width: dp(258),
                        height: dp(258),
                      );
                    },
                  ),
                ),
              )),
          Positioned(
            top: -dp(20),
            left: dp(182),
            // child: Transform.rotate(
            //   alignment: Alignment.topLeft,
            //   origin: Offset(dp(24), dp(44)),
            //   angle: -pi / (isPlay ? 40 : 5),
            //   child: Image.asset(
            //     'images/f60.png',
            //     width: dp(140),
            //   ),
            child: Consumer<AudioProvider>(
              builder: (context, value, _) {
                return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 250),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                          alignment: Alignment.topLeft,
                          origin: Offset(dp(24), dp(44)),
                          angle: value,
                          child: child);
                    },
                    child: Image.asset(
                      'images/f60.png',
                      width: dp(140),
                    ),
                    tween: Tween<double>(end: -pi / (value.isPlay ? 40 : 5)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget renderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'images/f4r.png',
          height: dp(38),
          width: dp(38),
        ),
        Image.asset(
          'images/f4b.png',
          height: dp(42),
          width: dp(42),
        ),
        Image.asset(
          'images/f5n.png',
          height: dp(40),
          width: dp(40),
        ),
        Image.asset(
          'images/f3k.png',
          height: dp(38),
          width: dp(38),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
                backgroundColor: Colors.transparent,
                barrierColor: Colors.transparent,
                isScrollControlled: true,
                builder: renderSongsModal,
                context: context);
          },
          child: Image.asset(
            'images/f4y.png',
            height: dp(30),
            width: dp(30),
          ),
        )
      ],
    );
  }

  Widget renderSongsModal(BuildContext constext) {
    return SizedBox(
      height: dp(700),
      child: Center(
        child: SizedBox(
          width: dp(500),
          child: Stack(
            children: [
              ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(dp(30)),
                                topRight: Radius.circular(dp(30)))),
                      ),
                    )),
              ),
              Consumer<AudioProvider>(builder: (_, value, __) {
                return Padding(
                    padding: EdgeInsets.all(dp(20)),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '当前播放',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: dp(22),
                                  height: 1),
                            ),
                            SizedBox(
                              width: dp(10),
                            ),
                            Text(
                              '(175)',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: dp(16),
                                  height: 1.2),
                            )
                          ],
                        ),
                        SizedBox(
                          height: dp(20),
                        ),
                        Flexible(
                            child: ListView.builder(
                                itemCount: value.songs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var song = value.songs[index];
                                  var active =
                                      song.url == value.currentSong!.url;
                                  return GestureDetector(
                                    onTap: () {
                                      audioProvider.play(song);
                                    },
                                    child: Container(
                                      height: dp(60),
                                      alignment: Alignment.center,
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                child: Text(
                                              song.name,
                                              style: TextStyle(
                                                  color: active
                                                      ? Colors.white
                                                      : Colors.white60,
                                                  fontSize: dp(20),
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            )),
                                            Text(' - ',
                                                style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: dp(18))),
                                            Text(song.artist,
                                                style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: dp(18)))
                                          ]),
                                    ),
                                  );
                                }))
                      ],
                    ));
              })
            ],
          ),
        ),
      ),
    );
  }
}
