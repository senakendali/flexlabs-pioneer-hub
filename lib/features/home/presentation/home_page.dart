import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_page.dart';
import '../data/home_service.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;

  const HomePage({
    super.key,
    required this.authService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeService homeService;
  late Future<HomeDashboardData> homeFuture;

  @override
  void initState() {
    super.initState();

    homeService = HomeService(
      apiClient: widget.authService.apiClient,
    );

    homeFuture = homeService.fetchHomeDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      homeFuture = homeService.fetchHomeDashboard();
    });

    await homeFuture;
  }

  Future<void> _logout(BuildContext context) async {
    await widget.authService.logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          authService: widget.authService,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeDashboardData>(
      future: homeFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? HomeDashboardData.empty();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        return Scaffold(
          backgroundColor: AppTheme.primary,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _PurpleHeader(
                  data: data,
                  isLoading: isLoading,
                  onLogout: () => _logout(context),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _refresh,
                    child: _HomeContent(
                      data: data,
                      isLoading: isLoading,
                      hasError: hasError,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PurpleHeader extends StatelessWidget {
  final HomeDashboardData data;
  final bool isLoading;
  final VoidCallback onLogout;

  const _PurpleHeader({
    required this.data,
    required this.isLoading,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(
                  Icons.settings_rounded,
                  size: 21,
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/flexlabs-logo-white.png',
                width: 148,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'FlexLabs',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  );
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: onLogout,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _StudentAvatar(
                avatarUrl: data.avatarUrl,
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? 'Hi, Pioneer!' : 'Hi, ${data.studentName}!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      data.programName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_rounded,
                          color: Color(0xFFE9DFFC),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data.batchName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE9DFFC),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeaderMetric(
                    value: isLoading ? '-' : data.updateCount.toString(),
                    label: 'Updates',
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _HeaderMetric(
                    value: isLoading ? '-' : data.discussionCount.toString(),
                    label: 'Discussions',
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _HeaderMetric(
                    value: isLoading ? '-' : data.mentoringCount.toString(),
                    label: 'Mentors',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _StudentAvatar({
    required this.avatarUrl,
  });

  String? _withCacheBuster(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    final cleanUrl = url.trim();
    final separator = cleanUrl.contains('?') ? '&' : '?';

    return '$cleanUrl${separator}v=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _withCacheBuster(avatarUrl);

    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: imageUrl == null
              ? const _AvatarFallback()
              : Image.network(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  headers: const {
                    'Accept': 'image/*',
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppTheme.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const _AvatarFallback();
                  },
                ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_rounded,
      color: AppTheme.primary,
      size: 46,
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE9DFFC),
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withOpacity(0.18),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeDashboardData data;
  final bool isLoading;
  final bool hasError;

  const _HomeContent({
    required this.data,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasError) ...[
              const _ErrorBanner(),
              const SizedBox(height: 18),
            ],
            if (isLoading) ...[
              const _LoadingCard(),
              const SizedBox(height: 24),
            ] else ...[
              _ActionRequiredSection(
                isProfileIncomplete: data.profileIncomplete,
              ),
              const SizedBox(height: 24),
            ],
            const _SectionHeader(
              title: 'Student Tools',
              actionText: 'All tools',
            ),
            const SizedBox(height: 14),
            _ToolGrid(data: data),
            const SizedBox(height: 26),
            const _SectionHeader(
              title: 'Learning Support',
              actionText: 'See all',
            ),
            const SizedBox(height: 14),
            _SupportCard(
              icon: Icons.campaign_rounded,
              title: 'Announcement',
              subtitle: data.latestAnnouncementTitle,
              tag: 'Academic',
              time: '${data.updateCount} updates',
              iconBackground: const Color(0xFFF1ECFA),
              iconColor: AppTheme.primary,
            ),
            const SizedBox(height: 13),
            _SupportCard(
              icon: Icons.forum_rounded,
              title: 'Discussion Board',
              subtitle: data.latestDiscussionTitle,
              tag: 'Community',
              time: '${data.discussionCount} posts',
              iconBackground: const Color(0xFFEAF7EF),
              iconColor: const Color(0xFF20A35B),
            ),
            const SizedBox(height: 13),
            _SupportCard(
              icon: Icons.video_call_rounded,
              title: '1-on-1 Mentoring',
              subtitle: 'Book a session for code review or debugging help.',
              tag: 'Mentoring',
              time: '${data.mentoringCount} mentors',
              iconBackground: const Color(0xFFFFF4E1),
              iconColor: const Color(0xFFCC7A00),
            ),
            const SizedBox(height: 26),
            const _SectionHeader(
              title: 'Community Rooms',
              actionText: 'Explore',
            ),
            const SizedBox(height: 14),
            _RoomCard(
              icon: Icons.chat_bubble_rounded,
              title: 'Coding Help',
              subtitle: 'Ask technical questions and share errors.',
              badge: '${data.discussionCount} posts',
            ),
            const SizedBox(height: 13),
            const _RoomCard(
              icon: Icons.workspaces_rounded,
              title: 'Project Discussion',
              subtitle: 'Discuss portfolio ideas and project progress.',
              badge: 'Open',
            ),
            const SizedBox(height: 13),
            const _RoomCard(
              icon: Icons.business_center_rounded,
              title: 'Career & Portfolio',
              subtitle: 'Prepare CV, portfolio, and interview readiness.',
              badge: 'Open',
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Loading your student dashboard...',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFD5D5),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: Color(0xFFB42318),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Some dashboard data failed to load. Please try again later.',
              style: TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRequiredSection extends StatelessWidget {
  final bool isProfileIncomplete;

  const _ActionRequiredSection({
    required this.isProfileIncomplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isProfileIncomplete) {
      return Column(
        children: [
          const _SectionHeader(
            title: 'Action Required',
            actionText: '0',
            isBadge: true,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF20A35B),
                  size: 30,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Your student profile looks good.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const _SectionHeader(
          title: 'Action Required',
          actionText: '1',
          isBadge: true,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF20A35B),
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Add your bio and learning goals so mentors can understand you better.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.all(
                    Radius.circular(999),
                  ),
                ),
                child: Text(
                  'Now',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final HomeDashboardData data;

  const _ToolGrid({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.46,
      crossAxisSpacing: 13,
      mainAxisSpacing: 13,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ToolCard(
          icon: Icons.sticky_note_2_rounded,
          title: 'Notes',
          subtitle: '${data.notesCount} saved notes',
          color: AppTheme.primary,
          background: AppTheme.primaryLight,
        ),
        _ToolCard(
          icon: Icons.workspace_premium_rounded,
          title: 'Certificate',
          subtitle: data.certificateCount > 0
              ? '${data.certificateCount} available'
              : 'Not available yet',
          color: const Color(0xFF20A35B),
          background: const Color(0xFFEAF7EF),
        ),
        _ToolCard(
          icon: Icons.description_rounded,
          title: 'Report Card',
          subtitle: data.reportCardCount > 0
              ? '${data.reportCardCount} available'
              : 'Not available yet',
          color: const Color(0xFFCC7A00),
          background: const Color(0xFFFFF4E1),
        ),
        const _ToolCard(
          icon: Icons.event_available_rounded,
          title: 'Schedule',
          subtitle: 'Upcoming sessions',
          color: Color(0xFF2F80ED),
          background: Color(0xFFEAF2FF),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final bool isBadge;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.isBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
              letterSpacing: -0.2,
            ),
          ),
        ),
        isBadge
            ? Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Text(
                actionText,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final String time;
  final Color iconBackground;
  final Color iconColor;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.time,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppTheme.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  const _RoomCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}