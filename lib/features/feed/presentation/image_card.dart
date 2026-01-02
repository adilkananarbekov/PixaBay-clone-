import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/styles.dart';
import '../../../data/models/pixabay_image.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.image,
    this.onTap,
  });

  final PixabayImage image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = image.webformatUrl.isNotEmpty ? image.webformatUrl : image.previewUrl;
    final hasDimensions = image.hasDimensions;

    if (!hasDimensions) {
      return Container(
        height: kLoadingCardHeight,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: kImageCardRadius,
        ),
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
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: kImageCardRadius,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: image.aspectRatio,
              child: CachedNetworkImage(
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
                errorWidget: (context, url, error) => Container(
                  color: kCardColor,
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: kImageOverlayGradient,
                ),
              ),
            ),
            Positioned(
              left: kPadding12,
              right: kPadding12,
              bottom: kPadding12,
              child: Text(
                image.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: kBodyRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
