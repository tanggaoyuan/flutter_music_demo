import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music/apis/song_api.dart';
import 'package:flutter_music/models/song_item_model.dart';
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:flutter_music/utils/base_class.dart';
import 'package:provider/provider.dart';

class MusicList extends StatefulWidget {
  MusicList({Key? key}) : super(key: key);

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> with BaseStateClass {
  @override
  void initState() {
    super.initState();
  }

  @override
  void onLoad(Duration time) {
    SongApi.getPlaylist(526887854).then((value) {
      audioProvider.updateSongs(value);
    });
    super.onLoad(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AudioProvider>(
        builder: (context, value, _) {
          return ListView.builder(
              itemCount: value.songs.length,
              itemBuilder: (BuildContext context, int index) {
                var data = value.songs[index];
                return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/audio', arguments: data);
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: dp(24)),
                      height: dp(80),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                                fontSize: dp(27),
                                color: const Color.fromRGBO(153, 153, 153, 1)),
                          ),
                          SizedBox(width: dp(24)),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.name,
                                style: TextStyle(
                                    fontSize: dp(24),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                data.artist,
                                style: TextStyle(
                                    fontSize: dp(19),
                                    color:
                                        const Color.fromRGBO(128, 128, 128, 1)),
                              )
                            ],
                          ))
                        ],
                      ),
                    ));
              });
        },
      ),
    );
  }
}
