import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/styles.dart';
import '../../feed/domain/feed_notifier.dart';
import '../../feed/presentation/image_card.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  const BoardDetailScreen({
    super.key,
    required this.title,
    required this.query,
  });

  final String title;
  final String query;

  @override
  ConsumerState<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen> {
  late final ScrollController _controller;
  late final FeedQuery _filter;

  @override
  void initState() {
    super.initState();
    _filter = FeedQuery(query: widget.query);
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
      ref.read(queryFeedProvider(_filter).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(queryFeedProvider(_filter));
    final pins = state.images;
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textHeightBehavior = defaultTextStyle.textHeightBehavior;
    final titleStyle = defaultTextStyle.style.merge(kBodyRegular);
    final subtitleStyle = defaultTextStyle.style.merge(kCaption);
    final subBoardInnerWidth = kSubBoardCardWidth - (kPadding8 * 2);
    final rawSubBoardImageSize =
        (subBoardInnerWidth - kBoardCollageSpacing) / 2;
    final subBoardImageSize =
        _snapToPixelDown(rawSubBoardImageSize, devicePixelRatio);
    final subBoardCollageHeight = _snapToPixelUp(
      (subBoardImageSize * 2) + kBoardCollageSpacing + (kPadding8 * 2),
      devicePixelRatio,
    );
    final subBoardTitleHeight = _snapToPixelUp(
      _measureTextHeight(
        text: 'Summer vibes',
        style: titleStyle,
        textScaler: textScaler,
        textHeightBehavior: textHeightBehavior,
      ),
      devicePixelRatio,
    );
    final subBoardSubtitleHeight = _snapToPixelUp(
      _measureTextHeight(
        text: '241 pins',
        style: subtitleStyle,
        textScaler: textScaler,
        textHeightBehavior: textHeightBehavior,
      ),
      devicePixelRatio,
    );
    final subBoardCardHeight = _snapToPixelUp(
      subBoardCollageHeight + kPadding8 + subBoardTitleHeight + kPadding4 + subBoardSubtitleHeight,
      devicePixelRatio,
    );
    final subBoardListHeight = subBoardCardHeight + (kPadding12 * 2);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
                child: _BoardHeader(title: widget.title),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPadding,
                  kPadding12,
                  kScreenPadding,
                  kPadding12,
                ),
                child: _CollaboratorsRow(avatars: _avatars),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
                child: _SecretRow(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPadding,
                  kPadding16,
                  kScreenPadding,
                  kPadding20,
                ),
                child: _CategoryRow(items: _categories),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: kScreenPadding),
                child: Text('Sub-boards', style: kHeadingMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: subBoardListHeight,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    kScreenPadding,
                    kPadding12,
                    kScreenPadding,
                    kPadding12,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return _SubBoardCard(
                      board: _subBoards[index],
                      imageSize: subBoardImageSize,
                      titleHeight: subBoardTitleHeight,
                      subtitleHeight: subBoardSubtitleHeight,
                      cardHeight: subBoardCardHeight,
                      textHeightBehavior: textHeightBehavior,
                      titleStyle: titleStyle,
                      subtitleStyle: subtitleStyle,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: kPadding12),
                  itemCount: _subBoards.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: kScreenPadding),
                child: Text('Pins', style: kHeadingMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPadding,
                kPadding12,
                kScreenPadding,
                kPadding20,
              ),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: kGridSpacingVertical,
                crossAxisSpacing: kGridSpacingHorizontal,
                childCount: pins.length,
                itemBuilder: (context, index) {
                  return ImageCard(image: pins[index]);
                },
              ),
            ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kScreenPadding),
                  child: _LoadingCard(),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: kPadding24),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kTopNavHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: _CircleIconButton(
              icon: AppIcons.chevronLeft,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Center(
            child: Text(
              title,
              style: kBodyRegular.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            right: 0,
            child: Row(
              children: const [
                _CircleIconButton(icon: AppIcons.filter),
                SizedBox(width: kPadding8),
                _CircleIconButton(icon: AppIcons.menu),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaboratorsRow extends StatelessWidget {
  const _CollaboratorsRow({required this.avatars});

  final List<String> avatars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final avatar in avatars)
          Padding(
            padding: const EdgeInsets.only(right: kPadding8),
            child: CircleAvatar(
              radius: kAvatarSize / 2,
              backgroundImage: CachedNetworkImageProvider(avatar),
            ),
          ),
        const SizedBox(width: kPadding4),
        const _CircleIconButton(icon: AppIcons.plus),
      ],
    );
  }
}

class _SecretRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(AppIcons.lock, color: kLightGray, size: kFilterIconSize),
        SizedBox(width: kPadding8),
        Text('Secret board', style: kCaption),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.items});

  final List<_CategoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in items)
          Column(
            children: [
              Container(
                width: kActionButtonSize,
                height: kActionButtonSize,
                decoration: const BoxDecoration(
                  color: kActionButtonColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: kWhite, size: kNavIconSize),
              ),
              const SizedBox(height: kCategoryLabelSpacing),
              Text(item.label, style: kCaption),
            ],
          ),
      ],
    );
  }
}

class _SubBoardCard extends StatelessWidget {
  const _SubBoardCard({
    required this.board,
    required this.imageSize,
    required this.titleHeight,
    required this.subtitleHeight,
    required this.cardHeight,
    required this.textHeightBehavior,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  final _SubBoard board;
  final double imageSize;
  final double titleHeight;
  final double subtitleHeight;
  final double cardHeight;
  final TextHeightBehavior? textHeightBehavior;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kSubBoardCardWidth,
      height: cardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(kPadding8),
            decoration: const BoxDecoration(
              color: kCardColor,
              borderRadius: kBoardCardRadius,
            ),
            child: Column(
              children: [
                _SubBoardRow(
                  leftUrl: board.imageUrls[0],
                  rightUrl: board.imageUrls[1],
                  size: imageSize,
                ),
                const SizedBox(height: kBoardCollageSpacing),
                _SubBoardRow(
                  leftUrl: board.imageUrls[2],
                  rightUrl: board.imageUrls[3],
                  size: imageSize,
                ),
              ],
            ),
          ),
          const SizedBox(height: kPadding8),
          SizedBox(
            height: titleHeight,
            child: Text(
              board.title,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textHeightBehavior: textHeightBehavior,
            ),
          ),
          const SizedBox(height: kPadding4),
          SizedBox(
            height: subtitleHeight,
            child: Text(
              board.subtitle,
              style: subtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textHeightBehavior: textHeightBehavior,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubBoardRow extends StatelessWidget {
  const _SubBoardRow({
    required this.leftUrl,
    required this.rightUrl,
    required this.size,
  });

  final String leftUrl;
  final String rightUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SubBoardImage(url: leftUrl, size: size),
        const SizedBox(width: kBoardCollageSpacing),
        _SubBoardImage(url: rightUrl, size: size),
      ],
    );
  }
}

class _SubBoardImage extends StatelessWidget {
  const _SubBoardImage({
    required this.url,
    required this.size,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: kCollageImageRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, value) => Container(color: kCardColor),
          errorWidget: (context, value, error) => Container(color: kCardColor),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: kActionButtonSize,
        height: kActionButtonSize,
        decoration: const BoxDecoration(
          color: kActionButtonColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kWhite, size: kNavIconSize),
      ),
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

class _CategoryItem {
  const _CategoryItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SubBoard {
  const _SubBoard({
    required this.title,
    required this.subtitle,
    required this.imageUrls,
  });

  final String title;
  final String subtitle;
  final List<String> imageUrls;
}

double _measureTextHeight({
  required String text,
  required TextStyle style,
  required TextScaler textScaler,
  required TextHeightBehavior? textHeightBehavior,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    textHeightBehavior: textHeightBehavior,
  )..layout();
  return painter.height;
}

double _snapToPixelDown(double value, double devicePixelRatio) {
  final pixels = (value * devicePixelRatio).floorToDouble();
  return pixels / devicePixelRatio;
}

double _snapToPixelUp(double value, double devicePixelRatio) {
  final pixels = (value * devicePixelRatio).ceilToDouble();
  return pixels / devicePixelRatio;
}

const List<String> _avatars = [
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=60&q=60',
  'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=60&q=60',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=60&q=60',
];

const List<_CategoryItem> _categories = [
  _CategoryItem('Shopping', AppIcons.pin),
  _CategoryItem('Ideas', AppIcons.lamp),
  _CategoryItem('Organise', AppIcons.grid),
  _CategoryItem('Notes', AppIcons.document),
];

const List<_SubBoard> _subBoards = [
  _SubBoard(
    title: 'Summer vibes',
    subtitle: '12 pins',
    imageUrls: [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=300&q=60',
      'https://images.unsplash.com/photo-1493558103817-58b2924bce98?auto=format&fit=crop&w=300&q=60',
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=300&q=60',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=300&q=60',
    ],
  ),
  _SubBoard(
    title: 'Pool days',
    subtitle: '8 pins',
    imageUrls: [
      'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=300&q=60',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=300&q=60',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=60',
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=300&q=60',
    ],
  ),
];
