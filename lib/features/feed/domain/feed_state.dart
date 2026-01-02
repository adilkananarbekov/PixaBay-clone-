import '../../../data/models/pixabay_image.dart';

enum FeedTab {
  explore,
  forYou,
}

class FeedState {
  const FeedState({
    required this.images,
    required this.isLoading,
    required this.isLoadingMore,
    required this.page,
    required this.hasReachedEnd,
    required this.errorMessage,
    required this.tab,
  });

  final List<PixabayImage> images;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final bool hasReachedEnd;
  final String? errorMessage;
  final FeedTab tab;

  factory FeedState.initial() {
    return const FeedState(
      images: [],
      isLoading: false,
      isLoadingMore: false,
      page: 1,
      hasReachedEnd: false,
      errorMessage: null,
      tab: FeedTab.explore,
    );
  }

  FeedState copyWith({
    List<PixabayImage>? images,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    bool? hasReachedEnd,
    String? errorMessage,
    FeedTab? tab,
  }) {
    return FeedState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: errorMessage,
      tab: tab ?? this.tab,
    );
  }
}
