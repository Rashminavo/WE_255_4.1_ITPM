import 'package:flutter/material.dart';
import 'app_colors.dart';
 
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});
 
  static const List<Map<String, dynamic>> _resources = [
    {
      'category': 'What is Ragging?',
      'icon': Icons.help_outline_rounded,
      'color': Color(0xFF2D6A4F),
      'items': [
        {
          'title': 'Definition & Overview',
          'desc':
              'Ragging refers to any act of physical or psychological abuse, harassment, or humiliation of a student by seniors.',
        },
        {
          'title': 'Types of Ragging',
          'desc':
              'Physical ragging, verbal abuse, cyber ragging, forced acts, financial exploitation, and social isolation.',
        },
      ],
    },
    {
      'category': 'Your Rights',
      'icon': Icons.gavel_rounded,
      'color': Color(0xFF1B4332),
      'items': [
        {
          'title': 'Right to Report',
          'desc':
              'Every student has the right to report ragging without fear. Anonymous complaints are also accepted.',
        },
        {
          'title': 'Right to Protection',
          'desc':
              'You are entitled to protection from retaliation. The institution must ensure your safety after a complaint.',
        },
        {
          'title': 'Right to Counseling',
          'desc':
              'Free counseling services must be provided to victims of ragging under university regulations.',
        },
      ],
    },
    {
      'category': 'Laws & Regulations',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF40916C),
      'items': [
        {
          'title': 'UGC Anti-Ragging Regulations',
          'desc':
              'The UGC mandates a zero-tolerance policy toward ragging in all higher educational institutions.',
        },
        {
          'title': 'Criminal Charges',
          'desc':
              'Ragging can attract IPC Sections 294, 323, 506 — covering obscenity, causing hurt, and criminal intimidation.',
        },
      ],
    },
    {
      'category': 'How to Stay Safe',
      'icon': Icons.shield_rounded,
      'color': Color(0xFF74C69D),
      'items': [
        {
          'title': 'Recognize Warning Signs',
          'desc':
              'Know when a "fun activity" crosses the line into humiliation, pressure, or physical harm.',
        },
        {
          'title': 'Build a Support Network',
          'desc':
              'Connect with trusted seniors, faculty mentors, and fellow students early in your academic journey.',
        },
        {
          'title': 'Document Incidents',
          'desc':
              'Keep notes, screenshots, or other evidence of any incident. This strengthens complaints significantly.',
        },
      ],
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
          'Resources',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          final section = _resources[index];
          return _ResourceSection(
            category: section['category'] as String,
            icon: section['icon'] as IconData,
            color: section['color'] as Color,
            items: section['items'] as List<Map<String, String>>,
          );
        },
      ),
    );
  }
}
 
class _ResourceSection extends StatefulWidget {
  final String category;
  final IconData icon;
  final Color color;
  final List<Map<String, String>> items;
 
  const _ResourceSection({
    required this.category,
    required this.icon,
    required this.color,
    required this.items,
  });
 
  @override
  State<_ResourceSection> createState() => _ResourceSectionState();
}
 
class _ResourceSectionState extends State<_ResourceSection> {
  bool _expanded = false;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            ...widget.items.map(
              (item) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['title']!,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        item['desc']!,
                        style: TextStyle(
                          color: AppColors.textMid,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),
          if (_expanded) const SizedBox(height: 8),
        ],
      ),
    );
  }
}
 


