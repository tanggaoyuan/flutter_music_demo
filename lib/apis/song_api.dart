import 'package:dio/dio.dart';
import 'package:flutter_music/models/song_item_model.dart';
import 'package:flutter_music/utils/http_util.dart';

class SongApi {
  static Future<List<SongItemModel>> getPlaylist(int id) async {
    try {
      var response = await axios
          .get<List>('https://api.yimian.xyz/msc/')
          .query({'type': 'playlist', 'id': id});
      List<SongItemModel> models = [];
      List.generate(response.data!.length, (index) {
        response.data![index]['index'] = index;
        models.add(SongItemModel.fromJson(response.data![index]));
      });
      return models;
    } catch (e) {
      return Future.error(e);
    }
  }
}
