import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'resources_screen.dart';
import 'quiz_screen.dart';
import 'consequences_flowchart_screen.dart';
import 'progress_badges_screen.dart';

class HubHomeScreen extends StatelessWidget {
  const HubHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.88,
                  children: [
                    _HubCard(
                      number: '01',
                      title: 'Resources',
                      subtitle: 'Learn about ragging & your rights',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.cardLight,
                      textColor: AppColors.darkGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ResourcesScreen()),
                      ),
                    ),
                    _HubCard(
                      number: '02',
                      title: 'Self-Care Scan',
                      subtitle: 'Understand your state of mind and take the next step',
                      icon: Icons.quiz_rounded,
                      color: AppColors.darkGreen,
                      textColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      ),
                    ),
                    _HubCard(
                      number: '03',
                      title: 'Report Roadmap',
                      subtitle: 'Know where your complaint stands at every step',
                      icon: Icons.account_tree_rounded,
                      color: AppColors.darkGreen,
                      textColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ConsequencesFlowchartScreen()),
                      ),
                    ),
                    _HubCard(
                      number: '04',
                      title: 'Progress &\nBadges',
                      subtitle: 'Track your learning journey',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.cardLight,
                      textColor: AppColors.darkGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProgressBadgesScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecoLine(),
              const SizedBox(width: 12),
              const Text(
                'AWARENESS &\nEDUCATION HUB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              _buildDecoLine(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your guide to a safe campus environment',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecoLine() {
    return Column(
      children: [
        Container(width: 28, height: 2.5, color: Colors.white54),
        const SizedBox(height: 4),
        Container(width: 20, height: 2.5, color: Colors.white38),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _HubCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.35),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Icon(icon, color: textColor.withValues(alpha: 0.8), size: 26),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 11,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: textColor, size: 14),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
