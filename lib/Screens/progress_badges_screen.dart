import 'package:flutter/material.dart';
import 'app_colors.dart';
 
class ProgressBadgesScreen extends StatelessWidget {
  const ProgressBadgesScreen({super.key});
 
  // Simulated user progress data
  static const int _quizzesCompleted = 3;
  static const int _totalQuizzes = 5;
  static const int _resourcesRead = 2;
  static const int _totalResources = 4;
  static const int _campusSafetyScore = 68;
 
  static const List<Map<String, dynamic>> _badges = [
    {
      'title': 'First Step',
      'desc': 'Completed your first quiz',
      'icon': Icons.star_rounded,
      'color': Color(0xFFFFD700),
      'earned': true,
    },
    {
      'title': 'Knowledge Seeker',
      'desc': 'Read 2 resource sections',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF40916C),
      'earned': true,
    },
    {
      'title': 'Quiz Champion',
      'desc': 'Score 100% on any quiz',
      'icon': Icons.emoji_events_rounded,
      'color': Color(0xFFE07B39),
      'earned': false,
    },
    {
      'title': 'Awareness Advocate',
      'desc': 'Complete all 5 quizzes',
      'icon': Icons.shield_rounded,
      'color': Color(0xFF2D6A4F),
      'earned': false,
    },
    {
      'title': 'Resource Master',
      'desc': 'Read all resource sections',
      'icon': Icons.school_rounded,
      'color': Color(0xFF7B61FF),
      'earned': false,
    },
    {
      'title': 'Campus Guardian',
      'desc': 'Reach a campus safety score of 90+',
      'icon': Icons.security_rounded,
      'color': Color(0xFFB5362A),
      'earned': false,
    },
  ];
 
  static const List<Map<String, dynamic>> _activities = [
    {
      'action': 'Completed Quiz — Ragging Laws',
      'score': '+10 pts',
      'time': '2 hours ago',
      'icon': Icons.quiz_rounded,
    },
    {
      'action': 'Read: Your Rights as a Student',
      'score': '+5 pts',
      'time': 'Yesterday',
      'icon': Icons.menu_book_rounded,
    },
    {
      'action': 'Completed Quiz — What is Ragging?',
      'score': '+10 pts',
      'time': '2 days ago',
      'icon': Icons.quiz_rounded,
    },
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Progress & Badges',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCampusSafetyScore(),
            const SizedBox(height: 20),
            _buildProgressCards(),
            const SizedBox(height: 20),
            _buildSectionTitle('🏅 Badges'),
            const SizedBox(height: 12),
            _buildBadgesGrid(),
            const SizedBox(height: 20),
            _buildSectionTitle('📅 Recent Activity'),
            const SizedBox(height: 12),
            _buildActivityList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
 
  Widget _buildCampusSafetyScore() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campus Safety Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep learning to improve your score!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _campusSafetyScore / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF74C69D)),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_campusSafetyScore / 100',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: _campusSafetyScore / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF74C69D)),
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  '$_campusSafetyScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildProgressCards() {
    return Row(
      children: [
        Expanded(
          child: _ProgressCard(
            title: 'Quizzes',
            current: _quizzesCompleted,
            total: _totalQuizzes,
            icon: Icons.quiz_rounded,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProgressCard(
            title: 'Resources',
            current: _resourcesRead,
            total: _totalResources,
            icon: Icons.menu_book_rounded,
            color: AppColors.mediumGreen,
          ),
        ),
      ],
    );
  }
 
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
 
  Widget _buildBadgesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: _badges.length,
      itemBuilder: (context, index) {
        final badge = _badges[index];
        final earned = badge['earned'] as bool;
        return _BadgeTile(
          title: badge['title'] as String,
          desc: badge['desc'] as String,
          icon: badge['icon'] as IconData,
          color: badge['color'] as Color,
          earned: earned,
        );
      },
    );
  }
 
  Widget _buildActivityList() {
    return Column(
      children: _activities
          .map(
            (a) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a['icon'] as IconData,
                        color: AppColors.darkGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['action'] as String,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a['time'] as String,
                          style: TextStyle(
                            color: AppColors.textMid,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a['score'] as String,
                      style: TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
 
class _ProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final IconData icon;
  final Color color;
 
  const _ProgressCard({
    required this.title,
    required this.current,
    required this.total,
    required this.icon,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$current / $total',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
 
class _BadgeTile extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final bool earned;
 
  const _BadgeTile({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.earned,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: earned ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned ? color.withValues(alpha: 0.4) : Colors.grey.shade300,
        ),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: earned
                  ? color.withValues(alpha: 0.12)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: earned ? color : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: earned ? AppColors.textDark : Colors.grey,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
          if (!earned)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.lock_rounded, color: Colors.grey, size: 10),
            ),
        ],
      ),
    );
  }
}
 


