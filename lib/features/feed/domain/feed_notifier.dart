import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../data/repositories/feed_repository.dart';
import 'feed_state.dart';

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier(
    this._repository, {
    this.query,
    this.imageType,
  }) : super(FeedState.initial()) {
    Future.microtask(loadInitial);
  }

  final FeedRepository _repository;
  final String? query;
  final String? imageType;

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      page: 1,
      hasReachedEnd: false,
      errorMessage: null,
    );

    try {
      final images = await _repository.fetchImages(
        page: 1,
        perPage: kDefaultPerPage,
        query: query,
        imageType: imageType,
      );
      state = state.copyWith(
        images: images,
        isLoading: false,
        page: 1,
        hasReachedEnd: images.length < kDefaultPerPage,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedEnd) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    final nextPage = state.page + 1;
    try {
      final images = await _repository.fetchImages(
        page: nextPage,
        perPage: kDefaultPerPage,
        query: query,
        imageType: imageType,
      );
      state = state.copyWith(
        images: [...state.images, ...images],
        isLoadingMore: false,
        page: nextPage,
        hasReachedEnd: images.length < kDefaultPerPage,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  void setTab(FeedTab tab) {
    state = state.copyWith(tab: tab);
  }
}

@immutable
class FeedQuery {
  const FeedQuery({
    this.query,
    this.imageType,
  });

  final String? query;
  final String? imageType;

  @override
  bool operator ==(Object other) {
    return other is FeedQuery && other.query == query && other.imageType == imageType;
  }

  @override
  int get hashCode => Object.hash(query, imageType);
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(repository);
});

final queryFeedProvider =
    StateNotifierProvider.family<FeedNotifier, FeedState, FeedQuery>((ref, filter) {
  final repository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(
    repository,
    query: filter.query,
    imageType: filter.imageType,
  );
});
