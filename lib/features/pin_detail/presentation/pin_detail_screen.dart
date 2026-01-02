import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../data/models/pixabay_image.dart';
import '../../feed/domain/feed_notifier.dart';
import '../../feed/presentation/image_card.dart';

class PinDetailScreen extends ConsumerStatefulWidget {
  const PinDetailScreen({
    super.key,
    required this.image,
  });

  final PixabayImage image;

  @override
  ConsumerState<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends ConsumerState<PinDetailScreen> {
  late final ScrollController _controller;
  late final FeedQuery _filter;

  String get _query {
    if (widget.image.tags.trim().isNotEmpty) {
      return widget.image.title;
    }
    return widget.image.user.isNotEmpty ? widget.image.user : 'inspiration';
  }

  @override
  void initState() {
    super.initState();
    _filter = FeedQuery(
      query: _query,
      imageType: widget.image.imageType,
    );
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
    final primaryTag = widget.image.primaryTag.trim().toLowerCase();
    final similar = state.images.where((item) {
      if (item.id == widget.image.id) {
        return false;
      }
      if (primaryTag.isEmpty) {
        return true;
      }
      return item.tags.toLowerCase().contains(primaryTag);
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverToBoxAdapter(
              child: _HeroSection(image: widget.image),
            ),
            SliverToBoxAdapter(
              child: _SponsorRow(brand: widget.image.user),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: screenPadding),
                child: Text('Similar pins', style: headingMedium),
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
                childCount: similar.length,
                itemBuilder: (context, index) {
                  final image = similar[index];
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: loadMoreRadius,
                    ),
                    child: const Text('Load more', style: bodyRegular),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.image});

  final PixabayImage image;

  @override
  Widget build(BuildContext context) {
    final imageUrl = image.largeImageUrl.isNotEmpty ? image.largeImageUrl : image.webformatUrl;
    final height = MediaQuery.sizeOf(context).height * pinHeroHeightRatio;

    return Padding(
      padding: const EdgeInsets.fromLTRB(screenPadding, AppSpacing.lg, screenPadding, AppSpacing.lg),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: pinDetailRadius,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) => Container(
                height: height,
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
              errorWidget: (context, url, error) => Container(
                height: height,
                color: cardColor,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleIcon(
                  icon: AppIcons.chevronLeft,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _CircleIcon(icon: AppIcons.menu, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorRow extends StatelessWidget {
  const _SponsorRow({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final displayBrand = brand.isNotEmpty ? brand : 'Pixabay';

    return Padding(
      padding: const EdgeInsets.fromLTRB(screenPadding, 0, screenPadding, AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: NavDimensions.actionButtonSize,
            height: NavDimensions.actionButtonSize,
            decoration: const BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                AppIcons.profile,
                color: white,
                size: sponsorLogoSize,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sponsored by', style: caption),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(displayBrand, style: bodyRegular),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: sponsorDotSize,
                      height: sponsorDotSize,
                      decoration: const BoxDecoration(
                        color: secondaryRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: const [
              _ActionIconButton(icon: AppIcons.pin),
              SizedBox(width: AppSpacing.sm),
              _ActionIconButton(icon: AppIcons.reply),
              SizedBox(width: AppSpacing.sm),
              _ActionIconButton(icon: AppIcons.menu),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.icon});

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

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

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
