import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/design_tokens.dart';
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
        height: loadingCardHeight,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: imageCardRadius,
        ),
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
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: imageCardRadius,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: image.aspectRatio,
              child: CachedNetworkImage(
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
                errorWidget: (context, url, error) => Container(
                  color: cardColor,
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: imageOverlayGradient,
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Text(
                image.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: bodyRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
