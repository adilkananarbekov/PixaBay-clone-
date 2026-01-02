import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/widgets/separator.dart';
import '../../feed/domain/feed_notifier.dart';
import '../../feed/presentation/image_card.dart';
import '../../pin_detail/presentation/pin_detail_screen.dart';

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
    if (remaining <= scrollLoadOffset) {
      ref.read(queryFeedProvider(_filter).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(queryFeedProvider(_filter));
    final pins = state.images;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: screenPadding),
              sliver: SliverToBoxAdapter(
                child: _BoardHeader(title: widget.title),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                screenPadding,
                AppSpacing.md,
                screenPadding,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: _CollaboratorsRow(avatars: _avatars),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: screenPadding),
              sliver: SliverToBoxAdapter(
                child: _SecretRow(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                screenPadding,
                AppSpacing.lg,
                screenPadding,
                AppSpacing.xl,
              ),
              sliver: SliverToBoxAdapter(
                child: _CategoryRow(items: _categories),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenPadding),
              sliver: SliverToBoxAdapter(
                child: Text('Sub-boards', style: headingMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: _SubBoardSection(boards: _subBoards),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenPadding),
              sliver: SliverToBoxAdapter(
                child: Text('Pins', style: headingMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                screenPadding,
                AppSpacing.md,
                screenPadding,
                AppSpacing.xl,
              ),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: gridSpacingVertical,
                crossAxisSpacing: gridSpacingHorizontal,
                childCount: pins.length,
                itemBuilder: (context, index) {
                  final image = pins[index];
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
            if (state.isLoadingMore)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: screenPadding),
                sliver: SliverToBoxAdapter(
                  child: _LoadingCard(),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
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
      height: NavDimensions.topHeight,
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
              style: bodyRegular.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            right: 0,
            child: Row(
              children: const [
                _CircleIconButton(icon: AppIcons.filter),
                SizedBox(width: AppSpacing.sm),
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
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundImage: CachedNetworkImageProvider(avatar),
            ),
          ),
        const SizedBox(width: AppSpacing.xs),
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
        Icon(AppIcons.lock, color: lightGray, size: filterIconSize),
        SizedBox(width: AppSpacing.sm),
        Text('Secret board', style: caption),
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
                width: NavDimensions.actionButtonSize,
                height: NavDimensions.actionButtonSize,
                decoration: const BoxDecoration(
                  color: actionButtonColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: white, size: NavDimensions.iconSize),
              ),
              const SizedBox(height: categoryLabelSpacing),
              Text(item.label, style: caption),
            ],
          ),
      ],
    );
  }
}

class _SubBoardSection extends StatelessWidget {
  const _SubBoardSection({required this.boards});

  final List<_SubBoard> boards;

  @override
  Widget build(BuildContext context) {
    final listHeight = _SubBoardCard.heightFor(context) + (AppSpacing.md * 2);
    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          screenPadding,
          AppSpacing.md,
          screenPadding,
          AppSpacing.md,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _SubBoardCard(board: boards[index]);
        },
        separatorBuilder: (context, index) => Separator.w12(),
        itemCount: boards.length,
      ),
    );
  }
}

class _SubBoardCard extends StatelessWidget {
  const _SubBoardCard({required this.board});

  final _SubBoard board;

  static double heightFor(BuildContext context) {
    return _SubBoardLayout.fromContext(context).cardHeight;
  }

  @override
  Widget build(BuildContext context) {
    final layout = _SubBoardLayout.fromContext(context);
    return SizedBox(
      width: subBoardCardWidth,
      height: layout.cardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: cardColor,
              borderRadius: boardCardRadius,
            ),
            child: Column(
              children: [
                _SubBoardRow(
                  leftUrl: board.imageUrls[0],
                  rightUrl: board.imageUrls[1],
                  size: layout.imageSize,
                ),
                const SizedBox(height: boardCollageSpacing),
                _SubBoardRow(
                  leftUrl: board.imageUrls[2],
                  rightUrl: board.imageUrls[3],
                  size: layout.imageSize,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: layout.titleHeight,
            child: Text(
              board.title,
              style: layout.titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textHeightBehavior: layout.textHeightBehavior,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: layout.subtitleHeight,
            child: Text(
              board.subtitle,
              style: layout.subtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textHeightBehavior: layout.textHeightBehavior,
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
        const SizedBox(width: boardCollageSpacing),
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
      borderRadius: collageImageRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, value) => Container(color: cardColor),
          errorWidget: (context, value, error) => Container(color: cardColor),
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
        width: NavDimensions.actionButtonSize,
        height: NavDimensions.actionButtonSize,
        decoration: const BoxDecoration(
          color: actionButtonColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: white, size: NavDimensions.iconSize),
      ),
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

class _SubBoardLayout {
  const _SubBoardLayout({
    required this.imageSize,
    required this.titleHeight,
    required this.subtitleHeight,
    required this.cardHeight,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.textHeightBehavior,
  });

  final double imageSize;
  final double titleHeight;
  final double subtitleHeight;
  final double cardHeight;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextHeightBehavior? textHeightBehavior;

  static _SubBoardLayout fromContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textHeightBehavior = defaultTextStyle.textHeightBehavior;
    final titleStyle = defaultTextStyle.style.merge(bodyRegular);
    final subtitleStyle = defaultTextStyle.style.merge(caption);
    final subBoardInnerWidth = subBoardCardWidth - (AppSpacing.sm * 2);
    final rawImageSize = (subBoardInnerWidth - boardCollageSpacing) / 2;
    final imageSize = _snapToPixelDown(rawImageSize, devicePixelRatio);
    final collageHeight = _snapToPixelUp(
      (imageSize * 2) + boardCollageSpacing + (AppSpacing.sm * 2),
      devicePixelRatio,
    );
    final titleHeight = _snapToPixelUp(
      _measureTextHeight(
        text: 'Summer vibes',
        style: titleStyle,
        textScaler: textScaler,
        textHeightBehavior: textHeightBehavior,
      ),
      devicePixelRatio,
    );
    final subtitleHeight = _snapToPixelUp(
      _measureTextHeight(
        text: '241 pins',
        style: subtitleStyle,
        textScaler: textScaler,
        textHeightBehavior: textHeightBehavior,
      ),
      devicePixelRatio,
    );
    final cardHeight = _snapToPixelUp(
      collageHeight + AppSpacing.sm + titleHeight + AppSpacing.xs + subtitleHeight,
      devicePixelRatio,
    );

    return _SubBoardLayout(
      imageSize: imageSize,
      titleHeight: titleHeight,
      subtitleHeight: subtitleHeight,
      cardHeight: cardHeight,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      textHeightBehavior: textHeightBehavior,
    );
  }
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
