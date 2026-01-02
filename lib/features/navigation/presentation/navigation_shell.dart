import 'package:flutter/material.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/design_tokens.dart';
import '../../boards/presentation/boards_screen.dart';
import '../../feed/presentation/feed_screen.dart';
import '../../messages/presentation/messages_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  void _setIndex(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;

    final screens = const [
      FeedScreen(),
      BoardsScreen(),
      MessagesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButton: SizedBox(
        width: FabDimensions.diameter,
        height: FabDimensions.diameter,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: primaryColor,
          elevation: FabDimensions.elevation,
          shape: const CircleBorder(),
          child: const Icon(
            AppIcons.plus,
            color: white,
            size: FabDimensions.plusSize,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: _setIndex,
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
      height: NavDimensions.bottomHeight + bottomPadding,
      child: SafeArea(
        top: false,
        child: BottomAppBar(
          color: backgroundColor,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: FabDimensions.notchMargin,
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
              const SizedBox(width: FabDimensions.diameter),
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
    final iconColor = selected ? primaryColor : white50;
    final labelColor = selected ? primaryColor : lightGray;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: iconColor, size: NavDimensions.iconSize),
              if (showBadge)
                Positioned(
                  right: -NavDimensions.badgeOffset,
                  top: -NavDimensions.badgeOffset,
                  child: SizedBox(
                    width: NavDimensions.badgeSize,
                    height: NavDimensions.badgeSize,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: secondaryRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: navLabel.copyWith(
              color: labelColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
