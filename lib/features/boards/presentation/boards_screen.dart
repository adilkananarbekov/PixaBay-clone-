import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/styles.dart';
import '../../board_detail/presentation/board_detail_screen.dart';

class BoardsScreen extends StatelessWidget {
  const BoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boards = _boards;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScaler = mediaQuery.textScaler;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final defaultTextStyle = DefaultTextStyle.of(context);
    final textHeightBehavior = defaultTextStyle.textHeightBehavior;
    final headingStyle = defaultTextStyle.style.merge(kHeadingMedium);
    final captionStyle = defaultTextStyle.style.merge(kCaption);
    final avatarVisualSize = kAvatarSize + (kAvatarBorderWidth * 2);

    final availableWidth = screenWidth - (kScreenPadding * 2);
    final rawCardWidth = (availableWidth - kGridSpacingHorizontal) / 2;
    final cardWidth = _snapToPixelDown(rawCardWidth, devicePixelRatio);
    final innerWidth = cardWidth - (kPadding8 * 2);
    final rawImageSize = (innerWidth - kBoardCollageSpacing) / 2;
    final collageImageSize = _snapToPixelDown(rawImageSize, devicePixelRatio);
    final collageHeight = _snapToPixelUp(
      (collageImageSize * 2) + kBoardCollageSpacing + (kPadding8 * 2),
      devicePixelRatio,
    );
    final titleHeight = _snapToPixelUp(
      _measureTextHeight(
        text: 'Beach travel...',
        style: headingStyle,
        textScaler: textScaler,
        textHeightBehavior: textHeightBehavior,
      ),
      devicePixelRatio,
    );
    final subtitleHeight = _snapToPixelUp(
      _measureTextHeight(
        text: '241 pins - 1 month',
        style: captionStyle,
        textScaler: textScaler,
        textHeightBehavior: textHeightBehavior,
      ),
      devicePixelRatio,
    );
    final metaHeight =
        subtitleHeight > avatarVisualSize ? subtitleHeight : avatarVisualSize;
    final cardHeight = _snapToPixelUp(
      collageHeight + kPadding12 + titleHeight + kPadding4 + metaHeight,
      devicePixelRatio,
    );

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kScreenPadding),
          child: Column(
            children: [
              SizedBox(
                height: kTopNavHeight,
                child: Row(
                  children: [
                    const _FilterButton(label: 'All'),
                    const SizedBox(width: kPadding12),
                    const _FilterButton(label: 'Last update'),
                    const Spacer(),
                    _CircleIconButton(icon: AppIcons.magnifier, onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: kPadding16),
              Expanded(
                child: GridView.builder(
                  itemCount: boards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: kGridSpacingHorizontal,
                    crossAxisSpacing: kGridSpacingHorizontal,
                    mainAxisExtent: cardHeight,
                  ),
                  itemBuilder: (context, index) {
                    final board = boards[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => BoardDetailScreen(
                              title: board.title,
                              query: board.query,
                            ),
                          ),
                        );
                      },
                      child: _BoardCard(
                        board: board,
                        collageImageSize: collageImageSize,
                        subtitleHeight: subtitleHeight,
                        metaHeight: metaHeight,
                        avatarVisualSize: avatarVisualSize,
                        devicePixelRatio: devicePixelRatio,
                        textHeightBehavior: textHeightBehavior,
                        headingStyle: headingStyle,
                        captionStyle: captionStyle,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kFilterButtonHeight,
      padding: const EdgeInsets.symmetric(horizontal: kPadding12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(kFilterButtonRadius),
      ),
      child: Row(
        children: [
          Text(label, style: kBodyRegular),
          const SizedBox(width: kPadding8),
          const Icon(
            AppIcons.arrowDown,
            color: kWhite,
            size: kFilterIconSize,
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

class _BoardCard extends StatelessWidget {
  const _BoardCard({
    required this.board,
    required this.collageImageSize,
    required this.subtitleHeight,
    required this.metaHeight,
    required this.avatarVisualSize,
    required this.devicePixelRatio,
    required this.textHeightBehavior,
    required this.headingStyle,
    required this.captionStyle,
  });

  final _Board board;
  final double collageImageSize;
  final double subtitleHeight;
  final double metaHeight;
  final double avatarVisualSize;
  final double devicePixelRatio;
  final TextHeightBehavior? textHeightBehavior;
  final TextStyle headingStyle;
  final TextStyle captionStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = constraints.maxWidth - (kPadding8 * 2);
        final maxImageSize = _snapToPixelDown(
          (innerWidth - kBoardCollageSpacing) / 2,
          devicePixelRatio,
        );
        final imageSize = collageImageSize <= maxImageSize
            ? collageImageSize
            : maxImageSize;

        return Column(
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
                  _CollageRow(
                    leftUrl: board.imageUrls[0],
                    rightUrl: board.imageUrls[1],
                    size: imageSize,
                  ),
                  const SizedBox(height: kBoardCollageSpacing),
                  _CollageRow(
                    leftUrl: board.imageUrls[2],
                    rightUrl: board.imageUrls[3],
                    size: imageSize,
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadding12),
            Text(
              board.title,
              style: headingStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textHeightBehavior: textHeightBehavior,
            ),
            const SizedBox(height: kPadding4),
            SizedBox(
              height: metaHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: subtitleHeight,
                        child: Text(
                          board.subtitle,
                          style: captionStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textHeightBehavior: textHeightBehavior,
                        ),
                      ),
                    ),
                  ),
                  if (board.collaborators.isNotEmpty)
                    _AvatarStack(
                      avatars: board.collaborators,
                      avatarVisualSize: avatarVisualSize,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CollageRow extends StatelessWidget {
  const _CollageRow({
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
        _CollageImage(url: leftUrl, size: size),
        const SizedBox(width: kBoardCollageSpacing),
        _CollageImage(url: rightUrl, size: size),
      ],
    );
  }
}

class _CollageImage extends StatelessWidget {
  const _CollageImage({
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

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.avatars,
    required this.avatarVisualSize,
  });

  final List<String> avatars;
  final double avatarVisualSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: avatarVisualSize,
      width: avatarVisualSize + (avatars.length - 1) * kAvatarOverlap,
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(
              left: i * kAvatarOverlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kBackgroundColor, width: kAvatarBorderWidth),
                ),
                child: CircleAvatar(
                  radius: kAvatarSize / 2,
                  backgroundImage: CachedNetworkImageProvider(avatars[i]),
                ),
              ),
            ),
        ],
      ),
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

class _Board {
  const _Board({
    required this.title,
    required this.query,
    required this.subtitle,
    required this.imageUrls,
    required this.collaborators,
  });

  final String title;
  final String query;
  final String subtitle;
  final List<String> imageUrls;
  final List<String> collaborators;
}

const List<_Board> _boards = [
  _Board(
    title: 'Beach travel ideas',
    query: 'beach travel',
    subtitle: '16 pins - 2 days',
    imageUrls: [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=60',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=410&q=60',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=420&q=60',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=430&q=60',
    ],
    collaborators: [
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=60&q=60',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=61&q=60',
    ],
  ),
  _Board(
    title: 'Dogs',
    query: 'dogs',
    subtitle: '24 pins - 7 days',
    imageUrls: [
      'https://images.unsplash.com/photo-1507146426996-ef05306b995a?auto=format&fit=crop&w=400&q=60',
      'https://images.unsplash.com/photo-1507146426996-ef05306b995a?auto=format&fit=crop&w=410&q=60',
      'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=420&q=60',
      'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=430&q=60',
    ],
    collaborators: [],
  ),
  _Board(
    title: 'Cats',
    query: 'cats',
    subtitle: '24 pins - 7 days',
    imageUrls: [
      'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=60',
      'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=410&q=60',
      'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=420&q=60',
      'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=430&q=60',
    ],
    collaborators: [],
  ),
  _Board(
    title: 'Food prep',
    query: 'food prep',
    subtitle: '241 pins - 1 month',
    imageUrls: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=60',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=410&q=60',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=420&q=60',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=430&q=60',
    ],
    collaborators: [
      'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=60&q=60',
    ],
  ),
];
