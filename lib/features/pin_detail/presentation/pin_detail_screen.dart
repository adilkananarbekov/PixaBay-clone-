import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/styles.dart';
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
    if (remaining <= kScrollLoadOffset) {
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
      backgroundColor: kBackgroundColor,
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
                padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
                child: Text('Similar pins', style: kHeadingMedium),
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
                childCount: similar.length,
                itemBuilder: (context, index) {
                  return ImageCard(image: similar[index]);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: kPadding24),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPadding24,
                      vertical: kPadding12,
                    ),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: kLoadMoreRadius,
                    ),
                    child: const Text('Load more', style: kBodyRegular),
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
    final height = MediaQuery.sizeOf(context).height * kPinHeroHeightRatio;

    return Padding(
      padding: const EdgeInsets.fromLTRB(kScreenPadding, kPadding16, kScreenPadding, kPadding16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: kPinDetailRadius,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) => Container(
                height: height,
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
              errorWidget: (context, url, error) => Container(
                height: height,
                color: kCardColor,
              ),
            ),
          ),
          Positioned(
            left: kPadding12,
            right: kPadding12,
            top: kPadding12,
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
      padding: const EdgeInsets.fromLTRB(kScreenPadding, 0, kScreenPadding, kPadding20),
      child: Row(
        children: [
          Container(
            width: kActionButtonSize,
            height: kActionButtonSize,
            decoration: const BoxDecoration(
              color: kCardColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                AppIcons.profile,
                color: kWhite,
                size: kSponsorLogoSize,
              ),
            ),
          ),
          const SizedBox(width: kPadding12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sponsored by', style: kCaption),
                const SizedBox(height: kPadding4),
                Row(
                  children: [
                    Text(displayBrand, style: kBodyRegular),
                    const SizedBox(width: kPadding8),
                    Container(
                      width: kSponsorDotSize,
                      height: kSponsorDotSize,
                      decoration: const BoxDecoration(
                        color: kSecondaryRed,
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
              SizedBox(width: kPadding8),
              _ActionIconButton(icon: AppIcons.reply),
              SizedBox(width: kPadding8),
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
