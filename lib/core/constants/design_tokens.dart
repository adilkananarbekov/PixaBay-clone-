import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFF0F0F0F);
const Color cardColor = Color(0xFF1A1A1A);
const Color primaryColor = Color(0xFFE60023);
const Color secondaryRed = Color(0xFFDC052A);
const Color white = Color(0xFFFFFFFF);
const Color lightGray = Color(0xFFA3A3A3);
const Color darkOverlay = Color(0x66000000);
const Color white50 = Color(0x80FFFFFF);
const Color actionButtonColor = Color(0x66000000);

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

abstract class AppRadius {
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 32.0;
}

abstract class NavDimensions {
  static const topHeight = 56.0;
  static const bottomHeight = 80.0;
  static const iconSize = 28.0;
  static const labelSize = 12.0;
  static const filterButtonHeight = 40.0;
  static const tabCapsuleHeight = 36.0;
  static const tabItemWidth = 100.0;
  static const actionButtonSize = 48.0;
  static const badgeSize = 10.0;
  static const badgeOffset = 2.0;
}

abstract class FabDimensions {
  static const diameter = 64.0;
  static const elevation = 6.0;
  static const plusSize = 28.0;
  static const notchMargin = 8.0;
}

const double screenPadding = AppSpacing.lg;
const double gridSpacingVertical = AppSpacing.xl;
const double gridSpacingHorizontal = AppSpacing.lg;
const double boardCollageSpacing = AppSpacing.sm;
const double boardCardRadiusValue = AppRadius.md;
const double collageRadiusValue = AppRadius.sm;
const double imageCardRadiusValue = AppRadius.sm;
const double pinDetailRadiusValue = AppRadius.lg;
const double loadMoreRadiusValue = AppRadius.sm;

const double filterButtonRadius = AppRadius.md;
const double filterIconSize = 16.0;
const double loaderSize = 24.0;
const double loaderStroke = 2.0;
const double exploreActionSpacing = AppSpacing.md;
const double sponsorDotSize = 8.0;
const double sponsorLogoSize = 20.0;
const double categoryLabelSpacing = 6.0;
const double subBoardCardWidth = 160.0;
const double subBoardImageHeight = 52.0;
const double subBoardCardHeight = 190.0;
const double tabIndicatorInset = 0.0;

const double avatarSize = 20.0;
const double avatarOverlap = 12.0;
const double avatarBorderWidth = 2.0;

const double ctaCardHeight = 240.0;
const double ctaArrowSize = 24.0;
const double ctaTitleSize = 18.0;
const double loadingCardHeight = 72.0;
const double skeletonCardHeightSmall = 220.0;
const double skeletonCardHeightLarge = 280.0;
const double pinHeroHeightRatio = 0.45;
const double scrollLoadOffset = 400.0;
const double ctaArrowRotation = 0.785;
const double ctaTitleLineHeight = 1.2;
const int explorePrefetchCount = 2;
const int exploreLoadAhead = 4;

const BorderRadius boardCardRadius = BorderRadius.all(
  Radius.circular(boardCardRadiusValue),
);
const BorderRadius collageImageRadius = BorderRadius.all(
  Radius.circular(collageRadiusValue),
);
const BorderRadius imageCardRadius = BorderRadius.all(
  Radius.circular(imageCardRadiusValue),
);
const BorderRadius pinDetailRadius = BorderRadius.vertical(
  top: Radius.circular(pinDetailRadiusValue),
);
const BorderRadius loadMoreRadius = BorderRadius.all(
  Radius.circular(loadMoreRadiusValue),
);

const TextStyle headingLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: white,
);

const TextStyle headingMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: white,
);

const TextStyle bodyRegular = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: white,
);

const TextStyle caption = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: lightGray,
);

const TextStyle navLabel = TextStyle(
  fontSize: NavDimensions.labelSize,
  fontWeight: FontWeight.w500,
  color: white50,
);

const LinearGradient imageOverlayGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x00000000),
    darkOverlay,
  ],
);
