import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/styles.dart';
import '../../boards/presentation/boards_screen.dart';
import '../../feed/presentation/feed_screen.dart';
import '../../messages/presentation/messages_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../navigation_provider.dart';

class NavigationShell extends ConsumerWidget {
  const NavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final screens = const [
      FeedScreen(),
      BoardsScreen(),
      MessagesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButton: SizedBox(
        width: kFabDiameter,
        height: kFabDiameter,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: kPrimaryColor,
          elevation: kFabElevation,
          shape: const CircleBorder(),
          child: const Icon(
            AppIcons.plus,
            color: kWhite,
            size: kFabPlusSize,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(navigationProvider.notifier).setIndex(index),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: kBottomNavHeight + bottomPadding,
      child: SafeArea(
        top: false,
        child: BottomAppBar(
          color: kBackgroundColor,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: kFabNotchMargin,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  label: 'Home',
                  icon: AppIcons.home,
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: 'Boards',
                  icon: AppIcons.grid,
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              const SizedBox(width: kFabDiameter),
              Expanded(
                child: _NavItem(
                  label: 'Messages',
                  icon: AppIcons.chat,
                  selected: currentIndex == 2,
                  showBadge: true,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: 'Profile',
                  icon: AppIcons.profile,
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.showBadge = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? kPrimaryColor : kWhite50;
    final labelColor = selected ? kPrimaryColor : kLightGray;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: iconColor, size: kNavIconSize),
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
          const SizedBox(height: kPadding4),
          Text(
            label,
            style: kNavLabel.copyWith(
              color: labelColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
