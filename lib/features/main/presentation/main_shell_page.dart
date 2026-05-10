import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../../community/presentation/community_page.dart';
import '../../home/presentation/home_page.dart';
import '../../mentoring/presentation/mentoring_page.dart';
import '../../profile/presentation/profile_page.dart';

class MainShellPage extends StatefulWidget {
  final AuthService authService;

  const MainShellPage({
    super.key,
    required this.authService,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    HomePage(
      authService: widget.authService,
    ),
    const CommunityPage(),
    const MentoringPage(),
    const ProfilePage(),
  ];

  void changeTab(int index) {
    if (index == currentIndex) return;

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _FloatingBottomNavBar(
        currentIndex: currentIndex,
        onChanged: changeTab,
      ),
    );
  }
}

class _FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _FloatingBottomNavBar({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FloatingNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              _FloatingNavItem(
                icon: Icons.forum_rounded,
                label: 'Community',
                isActive: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
              _FloatingNavItem(
                icon: Icons.video_call_rounded,
                label: 'Mentor',
                isActive: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
              _FloatingNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => onChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : AppTheme.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 14 : 10,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              if (isActive) ...[
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}