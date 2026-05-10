import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../data/community_service.dart';
import 'community_post_detail_page.dart';
import 'create_community_post_page.dart';

class CommunityPostsPage extends StatefulWidget {
  final AuthService authService;
  final CommunityChannel channel;

  const CommunityPostsPage({
    super.key,
    required this.authService,
    required this.channel,
  });

  @override
  State<CommunityPostsPage> createState() => _CommunityPostsPageState();
}

class _CommunityPostsPageState extends State<CommunityPostsPage> {
  late final CommunityService communityService;
  late Future<List<CommunityPost>> postsFuture;

  @override
  void initState() {
    super.initState();

    communityService = CommunityService(
      apiClient: widget.authService.apiClient,
    );

    postsFuture = communityService.fetchPosts(widget.channel.id);
  }

  Future<void> _refresh() async {
    setState(() {
      postsFuture = communityService.fetchPosts(widget.channel.id);
    });

    await postsFuture;
  }

  void _openPost(CommunityPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailPage(
          authService: widget.authService,
          post: post,
        ),
      ),
    );
  }

  Future<void> _openCreatePost() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateCommunityPostPage(
          authService: widget.authService,
          channel: widget.channel,
        ),
      ),
    );

    if (created == true) {
      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post berhasil dibuat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _refresh,
          child: FutureBuilder<List<CommunityPost>>(
            future: postsFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final hasError = snapshot.hasError;
              final posts = snapshot.data ?? [];

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 92),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PostsHeader(
                      channel: widget.channel,
                    ),
                    const SizedBox(height: 22),
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
                    ] else if (posts.isEmpty) ...[
                      const _EmptyPostCard(),
                    ] else ...[
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Posts',
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
                              '${posts.length} posts',
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
                      ...posts.map(
                        (post) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PostCard(
                            post: post,
                            onTap: () => _openPost(post),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          'New Post',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PostsHeader extends StatelessWidget {
  final CommunityChannel channel;

  const _PostsHeader({
    required this.channel,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  channel.isAnnouncement ? 'Official' : 'Discussion',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      channel.description,
                      style: const TextStyle(
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
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.isSolved || post.isAnnouncement) ...[
                Row(
                  children: [
                    if (post.isAnnouncement)
                      const _PostBadge(
                        label: 'Official',
                        icon: Icons.campaign_rounded,
                        color: AppTheme.primary,
                        background: AppTheme.primaryLight,
                      ),
                    if (post.isAnnouncement && post.isSolved)
                      const SizedBox(width: 8),
                    if (post.isSolved)
                      const _PostBadge(
                        label: 'Solved',
                        icon: Icons.check_circle_rounded,
                        color: Color(0xFF20A35B),
                        background: Color(0xFFEAF7EF),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Text(
                post.title,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${post.authorRole} • ${post.createdAtLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        post.commentsCount.toString(),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _PostBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
              'Loading posts...',
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
                  'Posts failed to load',
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

class _EmptyPostCard extends StatelessWidget {
  const _EmptyPostCard();

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
            Icons.chat_bubble_outline_rounded,
            color: AppTheme.primary,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No posts yet',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first Pioneer to start a discussion in this room.',
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