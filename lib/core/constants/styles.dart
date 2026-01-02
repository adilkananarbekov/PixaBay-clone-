import 'package:flutter/material.dart';

const Color kBackgroundColor = Color(0xFF0F0F0F);
const Color kCardColor = Color(0xFF1A1A1A);
const Color kPrimaryColor = Color(0xFFE60023);
const Color kSecondaryRed = Color(0xFFDC052A);
const Color kWhite = Color(0xFFFFFFFF);
const Color kLightGray = Color(0xFFA3A3A3);
const Color kDarkOverlay = Color(0x66000000);
const Color kWhite50 = Color(0x80FFFFFF);
const Color kActionButtonColor = Color(0x66000000);

const double kScreenPadding = 16.0;
const double kPadding24 = 24.0;
const double kPadding20 = 20.0;
const double kPadding16 = 16.0;
const double kPadding12 = 12.0;
const double kPadding8 = 8.0;
const double kPadding4 = 4.0;

const double kGridSpacingVertical = 20.0;
const double kGridSpacingHorizontal = 16.0;
const double kBoardCollageSpacing = 8.0;
const double kBoardCardRadiusValue = 20.0;
const double kCollageRadiusValue = 12.0;
const double kImageCardRadiusValue = 12.0;
const double kPinDetailRadiusValue = 32.0;
const double kLoadMoreRadiusValue = 12.0;

const double kFabDiameter = 64.0;
const double kBottomNavHeight = 80.0;
const double kNavIconSize = 28.0;
const double kNavLabelSize = 12.0;
const double kFabElevation = 6.0;
const double kFabPlusSize = 28.0;
const double kFabNotchMargin = 8.0;

const double kTopNavHeight = 56.0;
const double kFilterButtonHeight = 40.0;
const double kFilterButtonRadius = 20.0;
const double kFilterIconSize = 16.0;
const double kTabCapsuleHeight = 36.0;
const double kTabItemWidth = 100.0;
const double kActionButtonSize = 48.0;
const double kBadgeSize = 10.0;
const double kBadgeOffset = 2.0;
const double kLoaderSize = 24.0;
const double kLoaderStroke = 2.0;
const double kExploreActionSpacing = 12.0;
const double kSponsorDotSize = 8.0;
const double kSponsorLogoSize = 20.0;
const double kCategoryLabelSpacing = 6.0;
const double kSubBoardCardWidth = 160.0;
const double kSubBoardImageHeight = 52.0;
const double kSubBoardCardHeight = 190.0;
const double kTabIndicatorInset = 0.0;

const double kAvatarSize = 20.0;
const double kAvatarOverlap = 12.0;
const double kAvatarBorderWidth = 2.0;

const double kCtaCardHeight = 240.0;
const double kCtaArrowSize = 24.0;
const double kCtaTitleSize = 18.0;
const double kLoadingCardHeight = 72.0;
const double kSkeletonCardHeightSmall = 220.0;
const double kSkeletonCardHeightLarge = 280.0;
const double kPinHeroHeightRatio = 0.45;
const double kScrollLoadOffset = 400.0;
const double kCtaArrowRotation = 0.785;
const double kCtaTitleLineHeight = 1.2;
const int kExplorePrefetchCount = 2;
const int kExploreLoadAhead = 4;

const BorderRadius kBoardCardRadius = BorderRadius.all(
  Radius.circular(kBoardCardRadiusValue),
);
const BorderRadius kCollageImageRadius = BorderRadius.all(
  Radius.circular(kCollageRadiusValue),
);
const BorderRadius kImageCardRadius = BorderRadius.all(
  Radius.circular(kImageCardRadiusValue),
);
const BorderRadius kPinDetailRadius = BorderRadius.vertical(
  top: Radius.circular(kPinDetailRadiusValue),
);
const BorderRadius kLoadMoreRadius = BorderRadius.all(
  Radius.circular(kLoadMoreRadiusValue),
);

const TextStyle kHeadingLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kWhite,
);

const TextStyle kHeadingMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kWhite,
);

const TextStyle kBodyRegular = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: kWhite,
);

const TextStyle kCaption = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kLightGray,
);

const TextStyle kNavLabel = TextStyle(
  fontSize: kNavLabelSize,
  fontWeight: FontWeight.w500,
  color: kWhite50,
);

const LinearGradient kImageOverlayGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x00000000),
    kDarkOverlay,
  ],
);
