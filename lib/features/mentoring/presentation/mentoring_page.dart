import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MentoringPage extends StatelessWidget {
  const MentoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _MentoringHeader(),
              SizedBox(height: 24),
              Text(
                'Mentoring Support',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 14),
              _MentorActionCard(
                icon: Icons.bug_report_rounded,
                title: 'Debugging Help',
                subtitle: 'Book a session when your code gets stuck.',
              ),
              SizedBox(height: 14),
              _MentorActionCard(
                icon: Icons.rate_review_rounded,
                title: 'Code Review',
                subtitle: 'Ask mentors to review your project structure.',
              ),
              SizedBox(height: 14),
              _MentorActionCard(
                icon: Icons.work_rounded,
                title: 'Portfolio Guidance',
                subtitle: 'Prepare better projects for your portfolio.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentoringHeader extends StatelessWidget {
  const _MentoringHeader();

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
            color: AppTheme.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.video_call_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '1-on-1 Mentoring',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Book a mentoring session for debugging, project consultation, or portfolio guidance.',
            style: TextStyle(
              color: Color(0xFFE9DFFC),
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: null,
              icon: Icon(Icons.calendar_month_rounded),
              label: Text('Book Session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MentorActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 26,
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
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }
}