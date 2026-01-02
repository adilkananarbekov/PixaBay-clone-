import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/pixabay_image.dart';

class PixabayApi {
  const PixabayApi(this._dioClient);

  final DioClient _dioClient;

  Future<List<PixabayImage>> fetchImages({
    int page = 1,
    int perPage = defaultPerPage,
    String? query,
    String? imageType,
  }) async {
    if (pixabayApiKey.isEmpty) {
      throw Exception('Missing Pixabay API key.');
    }
    final trimmedQuery = query?.trim();
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '',
      queryParameters: {
        'key': pixabayApiKey,
        'page': page,
        'per_page': perPage,
        if (trimmedQuery != null && trimmedQuery.isNotEmpty) 'q': trimmedQuery,
        'image_type': imageType ?? 'photo',
        'orientation': 'vertical',
        'safesearch': true,
      },
      options: Options(responseType: ResponseType.json),
    );

    final data = response.data;
    if (data == null || data['hits'] is! List) {
      return const [];
    }

    final hits = data['hits'] as List<dynamic>;
    return hits
        .whereType<Map<String, dynamic>>()
        .map(PixabayImage.fromJson)
        .toList();
  }
}

final pixabayApiProvider = Provider<PixabayApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PixabayApi(dioClient);
});
