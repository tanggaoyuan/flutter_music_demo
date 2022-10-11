import 'dart:convert';

class SongItemModel {
  String album;
  String artist;
  String cover;
  int id;
  String lrc;
  String name;
  String url;
  int index;

  SongItemModel(
      {this.album = '',
      this.artist = '',
      this.cover = '',
      this.id = 0,
      this.lrc = '',
      this.name = '',
      this.index = 0,
      this.url = ''});

  static SongItemModel fromJson(Map json) {
    return SongItemModel(
        album: json['album'],
        artist: json['artist'],
        cover: json['cover'],
        id: json['id'],
        lrc: json['lrc'],
        name: json['name'],
        index: json['index'],
        url: json['url']);
  }

  toJson() {
    final Map<String, dynamic> data = Map();
    data['album'] = album;
    data['artist'] = artist;
    data['cover'] = cover;
    data['id'] = id;
    data['lrc'] = lrc;
    data['name'] = name;
    data['url'] = url;
    data['index'] = index;
    return data;
  }

  @override
  String toString() {
    try {
      return jsonEncode(toJson());
    } catch (e) {
      return super.toString();
    }
  }
}
