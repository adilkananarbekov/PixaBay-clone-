import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../data/models/pixabay_image.dart';
import '../domain/feed_notifier.dart';
import '../domain/feed_state.dart';
import 'image_card.dart';
import '../../pin_detail/presentation/pin_detail_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedProvider);

    return DefaultTabController(
      length: 2,
      initialIndex: state.tab == FeedTab.explore ? 0 : 1,
      child: SafeArea(
        child: Stack(
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const ExploreSingleView(),
                Padding(
                  padding: const EdgeInsets.only(top: NavDimensions.topHeight + AppSpacing.lg),
                  child: const FeedGrid(showCta: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: screenPadding),
              child: SizedBox(
                height: NavDimensions.topHeight,
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: AppIcons.bell,
                      showBadge: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxTabWidth = constraints.maxWidth / 2;
                          final tabWidth =
                              maxTabWidth < NavDimensions.tabItemWidth ? maxTabWidth : NavDimensions.tabItemWidth;

                          return Center(
                            child: SizedBox(
                              height: NavDimensions.tabCapsuleHeight,
                              child: TabBar(
                                isScrollable: true,
                                onTap: (index) {
                                  ref
                                      .read(feedProvider.notifier)
                                      .setTab(index == 0 ? FeedTab.explore : FeedTab.forYou);
                                },
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(filterButtonRadius),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: const EdgeInsets.all(tabIndicatorInset),
                                labelColor: backgroundColor,
                                unselectedLabelColor: white50,
                                labelStyle: bodyRegular.copyWith(fontWeight: FontWeight.w600),
                                unselectedLabelStyle: bodyRegular.copyWith(fontWeight: FontWeight.w500),
                                labelPadding: EdgeInsets.zero,
                                tabs: [
                                  SizedBox(
                                    width: tabWidth,
                                    child: const Center(child: Text('Explore')),
                                  ),
                                  SizedBox(
                                    width: tabWidth,
                                    child: const Center(child: Text('For you')),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _CircleIconButton(
                      icon: AppIcons.magnifier,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreSingleView extends ConsumerStatefulWidget {
  const ExploreSingleView({super.key});

  @override
  ConsumerState<ExploreSingleView> createState() => _ExploreSingleViewState();
}

class _ExploreSingleViewState extends ConsumerState<ExploreSingleView> {
  late final PageController _controller;
  late final ProviderSubscription<FeedState> _prefetchSubscription;
  int? _lastPrefetchIndex;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _prefetchSubscription = ref.listenManual<FeedState>(feedProvider, (previous, next) {
      if (!mounted || next.images.isEmpty) {
        return;
      }
      final pageIndex = _controller.hasClients
          ? (_controller.page?.round() ?? _controller.initialPage)
          : 0;
      _prefetchAround(pageIndex, next.images);
    });
  }

  @override
  void dispose() {
    _prefetchSubscription.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);
    final images = state.images;

    if (state.isLoading && images.isEmpty) {
      return const _ExploreSkeleton();
    }

    if (state.errorMessage != null && images.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(screenPadding),
          child: Text(
            'Unable to load the feed. Add a Pixabay API key to continue.',
            style: bodyRegular,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _controller,
      scrollDirection: Axis.vertical,
      itemCount: images.length,
      onPageChanged: (index) {
        if (index >= images.length - exploreLoadAhead) {
          ref.read(feedProvider.notifier).loadMore();
        }
        _prefetchAround(index, images);
      },
      itemBuilder: (context, index) {
        final image = images[index];
        return _ExploreHeroCard(
          image: image,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PinDetailScreen(image: image),
              ),
            );
          },
        );
      },
    );
  }

  void _prefetchAround(int index, List<PixabayImage> images) {
    if (_lastPrefetchIndex == index) {
      return;
    }
    _lastPrefetchIndex = index;
    for (var offset = 1; offset <= explorePrefetchCount; offset++) {
      final targetIndex = index + offset;
      if (targetIndex >= images.length) {
        break;
      }
      final image = images[targetIndex];
      final url = image.largeImageUrl.isNotEmpty ? image.largeImageUrl : image.webformatUrl;
      if (url.isEmpty) {
        continue;
      }
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }
}

class _ExploreSkeleton extends StatelessWidget {
  const _ExploreSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: screenPadding),
      child: ClipRRect(
        borderRadius: pinDetailRadius,
        child: Container(
          color: cardColor,
          child: const Center(
            child: SizedBox(
              width: loaderSize,
              height: loaderSize,
              child: CircularProgressIndicator(
                strokeWidth: loaderStroke,
                color: white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreHeroCard extends StatelessWidget {
  const _ExploreHeroCard({
    required this.image,
    required this.onTap,
  });

  final PixabayImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = image.largeImageUrl.isNotEmpty ? image.largeImageUrl : image.webformatUrl;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: screenPadding),
        child: ClipRRect(
          borderRadius: pinDetailRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) => Container(
                  color: cardColor,
                  child: const Center(
                    child: SizedBox(
                      width: loaderSize,
                      height: loaderSize,
                      child: CircularProgressIndicator(
                        strokeWidth: loaderStroke,
                        color: white,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(color: cardColor),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: imageOverlayGradient,
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(image.user, style: caption),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            image.title,
                            style: headingMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _ExploreActions(user: image.user),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreActions extends StatelessWidget {
  const _ExploreActions({required this.user});

  final String user;

  @override
  Widget build(BuildContext context) {
    final initial = user.isNotEmpty ? user.characters.first.toUpperCase() : 'P';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: NavDimensions.actionButtonSize / 2,
          backgroundColor: primaryColor,
          child: Text(
            initial,
            style: bodyRegular.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: exploreActionSpacing),
        const _ExploreActionButton(icon: AppIcons.pin),
        const SizedBox(height: exploreActionSpacing),
        const _ExploreActionButton(icon: AppIcons.reply),
        const SizedBox(height: exploreActionSpacing),
        const _ExploreActionButton(icon: AppIcons.menu),
      ],
    );
  }
}

class _ExploreActionButton extends StatelessWidget {
  const _ExploreActionButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NavDimensions.actionButtonSize,
      height: NavDimensions.actionButtonSize,
      decoration: const BoxDecoration(
        color: actionButtonColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: white, size: NavDimensions.iconSize),
    );
  }
}

class FeedGrid extends ConsumerStatefulWidget {
  const FeedGrid({
    super.key,
    required this.showCta,
  });

  final bool showCta;

  @override
  ConsumerState<FeedGrid> createState() => _FeedGridState();
}

class _FeedGridState extends ConsumerState<FeedGrid> {
  static const int _ctaIndex = 2;

  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _controller.position;
    if (!position.hasPixels || !position.hasContentDimensions) {
      return;
    }
    final remaining = position.maxScrollExtent - position.pixels;
    if (remaining <= scrollLoadOffset) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);
    final images = state.images;
    final baseItemCount = images.length + (widget.showCta ? 1 : 0);
    final totalCount = baseItemCount + (state.isLoadingMore ? 1 : 0);

    if (state.isLoading && images.isEmpty) {
      return _SkeletonGrid(controller: _controller);
    }

    if (state.errorMessage != null && images.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(screenPadding),
          child: Text(
            'Unable to load the feed. Add a Pixabay API key to continue.',
            style: bodyRegular,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: screenPadding,
            vertical: AppSpacing.md,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: gridSpacingVertical,
            crossAxisSpacing: gridSpacingHorizontal,
            childCount: totalCount,
            itemBuilder: (context, index) {
              if (state.isLoadingMore && index == totalCount - 1) {
                return const _LoadingCard();
              }

              if (widget.showCta && index == _ctaIndex) {
                return const _CtaCard();
              }

              final imageIndex = widget.showCta && index > _ctaIndex ? index - 1 : index;
              final image = images[imageIndex];
              return ImageCard(
                image: image,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PinDetailScreen(image: image),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      controller: controller,
      padding: const EdgeInsets.symmetric(
        horizontal: screenPadding,
        vertical: AppSpacing.md,
      ),
      crossAxisCount: 2,
      mainAxisSpacing: gridSpacingVertical,
      crossAxisSpacing: gridSpacingHorizontal,
      itemCount: 8,
      itemBuilder: (context, index) {
        final height = index.isEven ? skeletonCardHeightSmall : skeletonCardHeightLarge;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: imageCardRadius,
          ),
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: loadingCardHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: imageCardRadius,
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  const _CtaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ctaCardHeight,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: imageCardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Transform.rotate(
              angle: ctaArrowRotation,
              child: Icon(
                AppIcons.arrowRightUp,
                color: white,
                size: ctaArrowSize,
              ),
            ),
          ),
          Text(
            'Summer vibe\ninspiration',
            style: bodyRegular.copyWith(
              fontSize: ctaTitleSize,
              fontWeight: FontWeight.w600,
              height: ctaTitleLineHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: NavDimensions.actionButtonSize,
            height: NavDimensions.actionButtonSize,
            decoration: const BoxDecoration(
              color: actionButtonColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: white,
              size: NavDimensions.iconSize,
            ),
          ),
          if (showBadge)
            Positioned(
              right: -NavDimensions.badgeOffset,
              top: -NavDimensions.badgeOffset,
              child: Container(
                width: NavDimensions.badgeSize,
                height: NavDimensions.badgeSize,
                decoration: const BoxDecoration(
                  color: secondaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
