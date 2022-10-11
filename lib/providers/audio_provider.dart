import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_music/models/song_item_model.dart';
import 'package:flutter_music/pages/music_audio_page/music_progress_bar.dart';

class AudioProvider with ChangeNotifier {
  bool isPlay;
  double rotate;
  SongItemModel? currentSong;
  List<SongItemModel> songs = [];

  final MusicProgressBarController musicProgressBarController =
      MusicProgressBarController();
  late AudioPlayer _audioPlayer;

  AudioProvider({this.isPlay = false, this.rotate = 0.0}) {
    _audioPlayer = AudioPlayer();

    audio.onPlayerStateChanged.listen((event) {
      isPlay = event == PlayerState.PLAYING;
      if (event == PlayerState.COMPLETED) {
        next();
      } else {
        notifyListeners();
      }
    });

    audio.onAudioPositionChanged.listen((event) {
      audio.getDuration().then(musicProgressBarController.updateDuration);
      musicProgressBarController.updateCurrent(event.inMilliseconds);
    });
  }

  void updateSongs(List<SongItemModel> songs) {
    this.songs = songs;
    notifyListeners();
  }

  AudioPlayer get audio {
    return _audioPlayer;
  }

  void play(SongItemModel song) async {
    if (currentSong != null && song.url != currentSong!.url) {
      musicProgressBarController.updateCurrent(0);
      musicProgressBarController.updateDuration(0);
      rotate = 0;
    }
    currentSong = song;
    audio.play(song.url);
  }

  void next() {
    var index = currentSong!.index + 1;
    index = index > songs.length - 1 ? 0 : index;
    play(songs[index]);
    notifyListeners();
  }

  void up() {
    var index = currentSong!.index - 1;
    index = index < 0 ? songs.length - 1 : index;
    play(songs[index]);
    notifyListeners();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
