import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_service.dart';
import '../data/community_service.dart';

class CreateCommunityPostPage extends StatefulWidget {
  final AuthService authService;
  final CommunityChannel channel;

  const CreateCommunityPostPage({
    super.key,
    required this.authService,
    required this.channel,
  });

  @override
  State<CreateCommunityPostPage> createState() =>
      _CreateCommunityPostPageState();
}

class _CreateCommunityPostPageState extends State<CreateCommunityPostPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  late final CommunityService communityService;

  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    communityService = CommunityService(
      apiClient: widget.authService.apiClient,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      setState(() {
        errorMessage = 'Title dan content wajib diisi.';
      });
      return;
    }

    if (title.length < 5) {
      setState(() {
        errorMessage = 'Title minimal 5 karakter.';
      });
      return;
    }

    if (body.length < 10) {
      setState(() {
        errorMessage = 'Content minimal 10 karakter.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      await communityService.createPost(
        channelId: widget.channel.id,
        title: title,
        body: body,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Icon(
          icon,
          color: AppTheme.textMuted,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: AppTheme.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: AppTheme.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: AppTheme.primary,
          width: 1.4,
        ),
      ),
      alignLabelWithHint: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CreatePostHeader(
                channel: widget.channel,
              ),
              const SizedBox(height: 22),
              if (errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFFD5D5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: Color(0xFFB42318),
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB42318),
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post Details',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Write clearly so other Pioneers can understand and help faster.',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: titleController,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        label: 'Title',
                        hint: 'Example: Error saat fetch API di Flutter',
                        icon: Icons.title_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: bodyController,
                      enabled: !isSubmitting,
                      minLines: 7,
                      maxLines: 12,
                      keyboardType: TextInputType.multiline,
                      decoration: _inputDecoration(
                        label: 'Content',
                        hint:
                            'Jelaskan problem, context, error message, dan apa yang sudah dicoba.',
                        icon: Icons.notes_rounded,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _WritingTipCard(
                      channel: widget.channel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppTheme.background,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      side: const BorderSide(
                        color: AppTheme.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isSubmitting ? null : _submit,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      isSubmitting ? 'Posting...' : 'Publish Post',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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

class _CreatePostHeader extends StatelessWidget {
  final CommunityChannel channel;

  const _CreatePostHeader({
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
                onPressed: () => Navigator.of(context).pop(false),
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
                child: const Text(
                  'New Post',
                  style: TextStyle(
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

class _WritingTipCard extends StatelessWidget {
  final CommunityChannel channel;

  const _WritingTipCard({
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    final isCodingRoom = channel.iconType == IconType.coding;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: AppTheme.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCodingRoom
                  ? 'Tips: sertakan error message, file terkait, kode pendek, dan langkah yang sudah teman-teman coba.'
                  : 'Tips: buat judul yang jelas dan jelaskan context supaya diskusi lebih mudah dibantu.',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}