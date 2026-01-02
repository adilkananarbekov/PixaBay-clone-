import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/styles.dart';
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
                  padding: const EdgeInsets.only(top: kTopNavHeight + kPadding16),
                  child: const FeedGrid(showCta: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
              child: SizedBox(
                height: kTopNavHeight,
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: AppIcons.bell,
                      showBadge: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: kPadding12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxTabWidth = constraints.maxWidth / 2;
                          final tabWidth =
                              maxTabWidth < kTabItemWidth ? maxTabWidth : kTabItemWidth;

                          return Center(
                            child: SizedBox(
                              height: kTabCapsuleHeight,
                              child: TabBar(
                                isScrollable: true,
                                onTap: (index) {
                                  ref
                                      .read(feedProvider.notifier)
                                      .setTab(index == 0 ? FeedTab.explore : FeedTab.forYou);
                                },
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(kFilterButtonRadius),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: const EdgeInsets.all(kTabIndicatorInset),
                                labelColor: kBackgroundColor,
                                unselectedLabelColor: kWhite50,
                                labelStyle: kBodyRegular.copyWith(fontWeight: FontWeight.w600),
                                unselectedLabelStyle: kBodyRegular.copyWith(fontWeight: FontWeight.w500),
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
                    const SizedBox(width: kPadding12),
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
  int? _lastPrefetchIndex;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
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
          padding: const EdgeInsets.all(kScreenPadding),
          child: Text(
            'Unable to load the feed. Add a Pixabay API key to continue.',
            style: kBodyRegular,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || images.isEmpty) {
        return;
      }
      final pageIndex = _controller.hasClients
          ? (_controller.page?.round() ?? _controller.initialPage)
          : 0;
      _prefetchAround(pageIndex, images);
    });

    return PageView.builder(
      controller: _controller,
      scrollDirection: Axis.vertical,
      itemCount: images.length,
      onPageChanged: (index) {
        if (index >= images.length - kExploreLoadAhead) {
          ref.read(feedProvider.notifier).loadMore();
        }
        _prefetchAround(index, images);
      },
      itemBuilder: (context, index) {
        return _ExploreHeroCard(image: images[index]);
      },
    );
  }

  void _prefetchAround(int index, List<PixabayImage> images) {
    if (_lastPrefetchIndex == index) {
      return;
    }
    _lastPrefetchIndex = index;
    for (var offset = 1; offset <= kExplorePrefetchCount; offset++) {
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
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
      child: ClipRRect(
        borderRadius: kPinDetailRadius,
        child: Container(
          color: kCardColor,
          child: const Center(
            child: SizedBox(
              width: kLoaderSize,
              height: kLoaderSize,
              child: CircularProgressIndicator(
                strokeWidth: kLoaderStroke,
                color: kWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreHeroCard extends StatelessWidget {
  const _ExploreHeroCard({required this.image});

  final PixabayImage image;

  @override
  Widget build(BuildContext context) {
    final imageUrl = image.largeImageUrl.isNotEmpty ? image.largeImageUrl : image.webformatUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
      child: ClipRRect(
        borderRadius: kPinDetailRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) => Container(
                color: kCardColor,
                child: const Center(
                  child: SizedBox(
                    width: kLoaderSize,
                    height: kLoaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: kLoaderStroke,
                      color: kWhite,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(color: kCardColor),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: kImageOverlayGradient,
                ),
              ),
            ),
            Positioned(
              left: kPadding16,
              right: kPadding16,
              bottom: kPadding16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(image.user, style: kCaption),
                        const SizedBox(height: kPadding4),
                        Text(
                          image.title,
                          style: kHeadingMedium,
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
          radius: kActionButtonSize / 2,
          backgroundColor: kPrimaryColor,
          child: Text(
            initial,
            style: kBodyRegular.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: kExploreActionSpacing),
        const _ExploreActionButton(icon: AppIcons.pin),
        const SizedBox(height: kExploreActionSpacing),
        const _ExploreActionButton(icon: AppIcons.reply),
        const SizedBox(height: kExploreActionSpacing),
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
      width: kActionButtonSize,
      height: kActionButtonSize,
      decoration: const BoxDecoration(
        color: kActionButtonColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: kWhite, size: kNavIconSize),
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
    if (remaining <= kScrollLoadOffset) {
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
          padding: const EdgeInsets.all(kScreenPadding),
          child: Text(
            'Unable to load the feed. Add a Pixabay API key to continue.',
            style: kBodyRegular,
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
            horizontal: kScreenPadding,
            vertical: kPadding12,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: kGridSpacingVertical,
            crossAxisSpacing: kGridSpacingHorizontal,
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
        horizontal: kScreenPadding,
        vertical: kPadding12,
      ),
      crossAxisCount: 2,
      mainAxisSpacing: kGridSpacingVertical,
      crossAxisSpacing: kGridSpacingHorizontal,
      itemCount: 8,
      itemBuilder: (context, index) {
        final height = index.isEven ? kSkeletonCardHeightSmall : kSkeletonCardHeightLarge;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: kImageCardRadius,
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
      height: kLoadingCardHeight,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: kImageCardRadius,
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  const _CtaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kCtaCardHeight,
      padding: const EdgeInsets.all(kPadding16),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: kImageCardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Transform.rotate(
              angle: kCtaArrowRotation,
              child: Icon(
                AppIcons.arrowRightUp,
                color: kWhite,
                size: kCtaArrowSize,
              ),
            ),
          ),
          Text(
            'Summer vibe\ninspiration',
            style: kBodyRegular.copyWith(
              fontSize: kCtaTitleSize,
              fontWeight: FontWeight.w600,
              height: kCtaTitleLineHeight,
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
            width: kActionButtonSize,
            height: kActionButtonSize,
            decoration: const BoxDecoration(
              color: kActionButtonColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: kWhite,
              size: kNavIconSize,
            ),
          ),
          if (showBadge)
            Positioned(
              right: -kBadgeOffset,
              top: -kBadgeOffset,
              child: Container(
                width: kBadgeSize,
                height: kBadgeSize,
                decoration: const BoxDecoration(
                  color: kSecondaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
