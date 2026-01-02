import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../datasources/pixabay_api.dart';
import '../models/pixabay_image.dart';

class FeedRepository {
  const FeedRepository(this._api);

  final PixabayApi _api;

  Future<List<PixabayImage>> fetchImages({
    int page = 1,
    int perPage = defaultPerPage,
    String? query,
    String? imageType,
  }) {
    return _api.fetchImages(
      page: page,
      perPage: perPage,
      query: query,
      imageType: imageType,
    );
  }
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final api = ref.watch(pixabayApiProvider);
  return FeedRepository(api);
});
