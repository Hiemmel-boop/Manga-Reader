import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

final mangaDexApiProvider = Provider<MangaDexApi>((ref) {
  return MangaDexApi(ref.watch(dioClientProvider));
});

class MangaDexApi {
  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  MangaDexApi(this._dioClient);

  Future<Response> getMangaList({
    int limit = 20,
    int offset = 0,
    String? status,
    String? contentRating,
    int? year,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'includes[]': ['cover_art', 'author', 'artist'],
      'order[followedCount]': 'desc',
      'availableTranslatedLanguage[]': ['fr', 'en'],
    };

    if (status != null) params['status[]'] = status;
    if (contentRating != null) params['contentRating[]'] = contentRating;
    if (year != null) params['year'] = year;

    return await _dio.get('/manga', queryParameters: params);
  }

  Future<Response> searchManga(
      String query, {
        int limit = 20,
        int offset = 0,
        String? status,
        String? contentRating,
        int? year,
      }) async {
    final params = <String, dynamic>{
      'title': query,
      'limit': limit,
      'offset': offset,
      'includes[]': ['cover_art', 'author', 'artist'],
    };

    if (status != null) params['status[]'] = status;
    if (contentRating != null) params['contentRating[]'] = contentRating;
    if (year != null) params['year'] = year;

    return await _dio.get('/manga', queryParameters: params);
  }

  Future<Response> getMangaDetails(String mangaId) async {
    return await _dio.get('/manga/$mangaId', queryParameters: {
      'includes[]': ['cover_art', 'author', 'artist'],
    });
  }

  Future<Response> getMangaChapters(
      String mangaId, {
        int limit = 100,
        int offset = 0,
        String? language,
      }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'order[chapter]': 'asc',
      'includes[]': ['scanlation_group'],
    };

    if (language != null) {
      params['translatedLanguage[]'] = language;
    } else {
      params['translatedLanguage[]'] = ['fr', 'en'];
    }

    return await _dio.get('/manga/$mangaId/feed', queryParameters: params);
  }

  Future<Response> getChapterPages(String chapterId) async {
    return await _dio.get('/at-home/server/$chapterId');
  }
}