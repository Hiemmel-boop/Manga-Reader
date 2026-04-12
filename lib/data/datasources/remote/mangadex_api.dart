import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

final mangaDexApiProvider = Provider<MangaDexApi>((ref) {
  return MangaDexApi(ref.watch(dioClientProvider));
});

class MangaDexApi {
  final DioClient _dioClient;

  // GETTER POUR ACCÉDER AU DIO
  Dio get dio => _dioClient.dio;

  MangaDexApi(this._dioClient);

  Future<Response> getMangaList({int limit = 20, int offset = 0}) async {
    return await dio.get('/manga', queryParameters: {
      'limit': limit,
      'offset': offset,
      'includes[]': 'cover_art',
    });
  }

  Future<Response> searchManga(String query, {int limit = 20}) async {
    return await dio.get('/manga', queryParameters: {
      'title': query,
      'limit': limit,
      'includes[]': 'cover_art',
    });
  }

  Future<Response> getMangaDetails(String mangaId) async {
    return await dio.get('/manga/$mangaId', queryParameters: {
      'includes[]': ['cover_art', 'author', 'artist'],
    });
  }

  Future<Response> getMangaChapters(String mangaId, {int limit = 100, String? language}) async {
    final params = {
      'limit': limit,
      'order[chapter]': 'asc',
      'includes[]': 'scanlation_group',
    };

    if (language != null) {
      params['translatedLanguage[]'] = language;
    }

    return await dio.get('/manga/$mangaId/feed', queryParameters: params);
  }

  Future<Response> getChapterPages(String chapterId) async {
    return await dio.get('/at-home/server/$chapterId');
  }
}