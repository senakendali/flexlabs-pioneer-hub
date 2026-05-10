import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../data/community_service.dart';
import 'community_posts_page.dart';

class CommunityPage extends StatefulWidget {
  final AuthService authService;

  const CommunityPage({
    super.key,
    required this.authService,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityService communityService;
  late Future<List<CommunityChannel>> channelsFuture;

  @override
  void initState() {
    super.initState();

    communityService = CommunityService(
      apiClient: widget.authService.apiClient,
    );

    channelsFuture = communityService.fetchChannels();
  }

  Future<void> _refresh() async {
    setState(() {
      channelsFuture = communityService.fetchChannels();
    });

    await channelsFuture;
  }

  void _openChannel(CommunityChannel channel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostsPage(
          authService: widget.authService,
          channel: channel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _refresh,
          child: FutureBuilder<List<CommunityChannel>>(
            future: channelsFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final hasError = snapshot.hasError;
              final channels = snapshot.data ?? [];

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CommunityHeader(),
                    const SizedBox(height: 24),
                    if (isLoading) ...[
                      const _LoadingCard(),
                    ] else if (hasError) ...[
                      _ErrorCard(
                        message: snapshot.error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                        onRetry: _refresh,
                      ),
                    ] else if (channels.isEmpty) ...[
                      const _EmptyCard(),
                    ] else ...[
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Community Rooms',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${channels.length} rooms',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...channels.map(
                        (channel) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _RoomCard(
                            channel: channel,
                            onTap: () => _openChannel(channel),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ask questions, share progress, and stay connected with Flexlabs.',
                  style: TextStyle(
                    color: Color(0xFFE9DFFC),
                    fontSize: 13.5,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
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

class _RoomCard extends StatelessWidget {
  final CommunityChannel channel;
  final VoidCallback onTap;

  const _RoomCard({
    required this.channel,
    required this.onTap,
  });

  IconData get icon {
    switch (channel.iconType) {
      case IconType.announcement:
        return Icons.campaign_rounded;
      case IconType.coding:
        return Icons.code_rounded;
      case IconType.project:
        return Icons.workspaces_rounded;
      case IconType.career:
        return Icons.business_center_rounded;
      case IconType.discussion:
        return Icons.chat_bubble_rounded;
    }
  }

  Color get iconColor {
    switch (channel.iconType) {
      case IconType.announcement:
        return AppTheme.primary;
      case IconType.coding:
        return const Color(0xFF2F80ED);
      case IconType.project:
        return const Color(0xFF20A35B);
      case IconType.career:
        return const Color(0xFFCC7A00);
      case IconType.discussion:
        return AppTheme.primary;
    }
  }

  Color get iconBackground {
    switch (channel.iconType) {
      case IconType.announcement:
        return AppTheme.primaryLight;
      case IconType.coding:
        return const Color(0xFFEAF2FF);
      case IconType.project:
        return const Color(0xFFEAF7EF);
      case IconType.career:
        return const Color(0xFFFFF4E1);
      case IconType.discussion:
        return AppTheme.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
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
                  borderRadius: BorderRadius.circular(21),
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
                    Text(
                      channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      channel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: iconBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            channel.isAnnouncement ? 'Official' : 'Discussion',
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${channel.postsCount} posts',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
        border: Border.all(color: AppTheme.border),
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
              'Loading community rooms...',
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

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFD5D5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: Color(0xFFB42318),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Community failed to load',
                  style: TextStyle(
                    color: Color(0xFFB42318),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFB42318),
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: FilledButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.forum_outlined,
            color: AppTheme.primary,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No community rooms yet',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Rooms from your batch will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}