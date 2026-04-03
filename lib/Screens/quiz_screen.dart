import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────
// When your counselor/booking page is ready, import it here:
// import 'counselor_booking_page.dart';
// ─────────────────────────────────────────────────────────────

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  // Stores selected option index per question
  final List<int?> _selectedAnswers = List.filled(10, null);
  bool _quizComplete = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Mental Health Assessment Questions ───────────────────────
  // Each question has 4 options scored 0–3:
  //   0 = healthiest / most aware response
  //   3 = most distressed / least aware response
  //
  // Total score range: 0 – 30
  //   0–9   → Mentally healthy, good awareness
  //   10–18 → Mild concern, counseling suggested
  //   19–30 → High concern, counseling strongly recommended
  // ────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _questions = [
    {
      'question':
          'How often do you feel stressed or overwhelmed by situations on campus?',
      'category': 'Stress',
      'icon': '😰',
      'options': [
        {'text': 'Rarely or never', 'score': 0},
        {'text': 'Sometimes, but I manage it well', 'score': 1},
        {'text': 'Often, and it\'s hard to cope', 'score': 2},
        {'text': 'Almost always — I feel constantly overwhelmed', 'score': 3},
      ],
    },
    {
      'question':
          'Have you ever felt pressured, humiliated, or forced to do something against your will by seniors or peers?',
      'category': 'Ragging Experience',
      'icon': '😔',
      'options': [
        {'text': 'No, never', 'score': 0},
        {'text': 'Once or twice, but it was minor', 'score': 1},
        {'text': 'Yes, it has happened a few times', 'score': 2},
        {'text': 'Yes, it happens regularly and affects me deeply', 'score': 3},
      ],
    },
    {
      'question': 'How would you describe your sleep patterns recently?',
      'category': 'Sleep & Rest',
      'icon': '😴',
      'options': [
        {'text': 'I sleep well and feel rested', 'score': 0},
        {'text': 'Occasionally disrupted but mostly fine', 'score': 1},
        {
          'text': 'I often have trouble sleeping due to worry or anxiety',
          'score': 2
        },
        {
          'text': 'I barely sleep and wake up feeling exhausted most days',
          'score': 3
        },
      ],
    },
    {
      'question':
          'When something difficult happens to you on campus, what do you typically do?',
      'category': 'Coping Skills',
      'icon': '🤔',
      'options': [
        {'text': 'Talk to someone I trust and find a solution', 'score': 0},
        {
          'text': 'Try to handle it on my own, usually successfully',
          'score': 1
        },
        {'text': 'Avoid thinking about it and hope it goes away', 'score': 2},
        {'text': 'Feel helpless and don\'t know what to do', 'score': 3},
      ],
    },
    {
      'question':
          'How comfortable do you feel speaking up or reporting if someone treats you unfairly?',
      'category': 'Confidence & Voice',
      'icon': '🗣️',
      'options': [
        {
          'text': 'Very comfortable — I know my rights and how to report',
          'score': 0
        },
        {'text': 'Somewhat comfortable, though a little hesitant', 'score': 1},
        {
          'text': 'Uncomfortable — I worry about consequences if I speak up',
          'score': 2
        },
        {
          'text':
              'Very uncomfortable — I feel too scared or ashamed to say anything',
          'score': 3
        },
      ],
    },
    {
      'question': 'How do you feel about your social connections on campus?',
      'category': 'Social Support',
      'icon': '👥',
      'options': [
        {
          'text': 'I have a strong support network of friends and mentors',
          'score': 0
        },
        {'text': 'I have a few close people I can rely on', 'score': 1},
        {'text': 'I feel somewhat isolated but manage', 'score': 2},
        {'text': 'I feel very alone and disconnected from others', 'score': 3},
      ],
    },
    {
      'question':
          'In the past few weeks, have you felt sad, hopeless, or lost interest in things you usually enjoy?',
      'category': 'Emotional Well-being',
      'icon': '💭',
      'options': [
        {'text': 'No, I\'ve generally felt positive and engaged', 'score': 0},
        {'text': 'Occasionally, but it passes quickly', 'score': 1},
        {'text': 'Yes, fairly often and it bothers me', 'score': 2},
        {'text': 'Yes, almost every day and I can\'t shake it', 'score': 3},
      ],
    },
    {
      'question':
          'How well do you feel you can focus on your studies or daily responsibilities?',
      'category': 'Focus & Productivity',
      'icon': '📚',
      'options': [
        {
          'text': 'Very well — I stay on track without much difficulty',
          'score': 0
        },
        {'text': 'Fairly well, with occasional distractions', 'score': 1},
        {
          'text': 'I struggle to focus and it\'s affecting my performance',
          'score': 2
        },
        {
          'text': 'I can\'t focus at all — everything feels pointless',
          'score': 3
        },
      ],
    },
    {
      'question':
          'Have you ever witnessed ragging or bullying happening to someone else and felt unsure what to do?',
      'category': 'Bystander Awareness',
      'icon': '👀',
      'options': [
        {'text': 'No, and I know exactly what to do if I ever do', 'score': 0},
        {'text': 'Yes, and I did try to help or report it', 'score': 1},
        {'text': 'Yes, but I didn\'t know how to intervene', 'score': 2},
        {'text': 'Yes, and I was too afraid to do anything', 'score': 3},
      ],
    },
    {
      'question':
          'How do you feel about your overall mental well-being right now?',
      'category': 'Overall Well-being',
      'icon': '🧠',
      'options': [
        {'text': 'Good — I feel mentally strong and balanced', 'score': 0},
        {'text': 'Okay — there are challenges but I\'m managing', 'score': 1},
        {'text': 'Not great — I often feel mentally drained', 'score': 2},
        {'text': 'Poor — I feel like I\'m really struggling', 'score': 3},
      ],
    },
  ];

  int get _totalScore {
    int total = 0;
    for (int i = 0; i < _selectedAnswers.length; i++) {
      final selected = _selectedAnswers[i];
      if (selected != null) {
        total += _questions[i]['options'][selected]['score'] as int;
      }
    }
    return total;
  }

  _QuizResult _getResult() {
    final score = _totalScore;
    if (score <= 9) return _QuizResult.healthy;
    if (score <= 18) return _QuizResult.mildConcern;
    return _QuizResult.highConcern;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      _selectedAnswers[_currentIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswers[_currentIndex] == null) {
      // Nudge user to select an answer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Please select an answer to continue.',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      _animController.reset();
      setState(() => _currentIndex++);
      _animController.forward();
    } else {
      setState(() => _quizComplete = true);
      // Auto-show counselor alert if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = _getResult();
        if (result != _QuizResult.healthy) {
          _showCounselorAlert(result);
        }
      });
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      _animController.reset();
      setState(() => _currentIndex--);
      _animController.forward();
    }
  }

  void _restartQuiz() {
    _animController.reset();
    setState(() {
      _currentIndex = 0;
      for (int i = 0; i < _selectedAnswers.length; i++) {
        _selectedAnswers[i] = null;
      }
      _quizComplete = false;
    });
    _animController.forward();
  }

  // ── Counselor Alert Dialog ───────────────────────────────────
  void _showCounselorAlert(_QuizResult result) {
    final bool isUrgent = result == _QuizResult.highConcern;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.danger.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUrgent
                      ? Icons.health_and_safety_rounded
                      : Icons.volunteer_activism_rounded,
                  color: isUrgent ? AppColors.danger : AppColors.warning,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isUrgent
                    ? 'We\'re Concerned About You'
                    : 'We Recommend Talking to Someone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isUrgent ? AppColors.danger : AppColors.warning,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Divider line
              Container(
                height: 2,
                width: 50,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.danger.withValues(alpha: 0.3)
                      : AppColors.warning.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Body text
              Text(
                isUrgent
                    ? 'Your responses indicate you may be experiencing significant emotional distress. Speaking with a professional counselor can make a real difference. You don\'t have to face this alone — support is available for you.'
                    : 'Your responses suggest some emotional challenges that could benefit from professional guidance. A counseling session is a safe space to talk through what you\'re feeling and get the support you deserve.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // What to expect section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What to expect from a session:',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _expectationRow(
                        Icons.lock_rounded, 'Completely confidential'),
                    _expectationRow(Icons.sentiment_satisfied_alt_rounded,
                        'Non-judgmental support'),
                    _expectationRow(
                        Icons.lightbulb_rounded, 'Practical coping strategies'),
                    _expectationRow(
                        Icons.favorite_rounded, 'A safe space to be heard'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // ── Navigate to your counselor booking page ──
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const CounselorBookingPage(),
                    //   ),
                    // );
                    // ────────────────────────────────────────────
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text(
                              'Redirecting to Counselor Booking...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text(
                    'Book a Counselor Now',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Maybe later
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMid,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expectationRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkGreen, size: 15),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textMid,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Mental Wellness Check',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _quizComplete ? _buildResultScreen() : _buildQuizScreen(),
    );
  }

  // ── Quiz Screen ──────────────────────────────────────────────
  Widget _buildQuizScreen() {
    final q = _questions[_currentIndex];
    final options = q['options'] as List<Map<String, dynamic>>;
    final selectedOption = _selectedAnswers[_currentIndex];

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.lightGreen),
            minHeight: 5,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Category chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${q['icon']}  ${q['category']}',
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Question card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      q['question'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Answer options
                  ...List.generate(options.length, (i) {
                    final isSelected = selectedOption == i;
                    return GestureDetector(
                      onTap: () => _selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.darkGreen : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.darkGreen
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Option letter bubble
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppColors.darkGreen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[i]['text'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textDark,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _prevQuestion,
                            icon:
                                const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text('Back'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkGreen,
                              side:
                                  const BorderSide(color: AppColors.darkGreen),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _currentIndex < _questions.length - 1
                                ? 'Next →'
                                : 'See My Results',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result Screen ────────────────────────────────────────────
  Widget _buildResultScreen() {
    final result = _getResult();
    final score = _totalScore;
    final maxScore = _questions.length * 3; // 30

    final Map<_QuizResult, Map<String, dynamic>> config = {
      _QuizResult.healthy: {
        'icon': Icons.sentiment_very_satisfied_rounded,
        'color': Colors.green,
        'bgColor': const Color(0xFFE8F5E9),
        'title': 'You\'re Doing Well! 🎉',
        'subtitle': 'Mentally Healthy',
        'message':
            'Your responses suggest you have a good level of mental well-being and awareness. You\'re managing stress well and have strong coping skills. Keep maintaining these healthy habits and continue supporting others around you.',
        'tag': '✅ No Counseling Needed',
        'showBooking': false,
      },
      _QuizResult.mildConcern: {
        'icon': Icons.sentiment_neutral_rounded,
        'color': AppColors.warning,
        'bgColor': const Color(0xFFFFF3E0),
        'title': 'Some Areas to Work On',
        'subtitle': 'Mild Concern',
        'message':
            'Your responses indicate some emotional challenges that could benefit from professional guidance. Talking to a counselor is a positive step — it\'s a safe, confidential space to share your feelings and get practical support.',
        'tag': '💡 Counseling Suggested',
        'showBooking': true,
      },
      _QuizResult.highConcern: {
        'icon': Icons.sentiment_very_dissatisfied_rounded,
        'color': AppColors.danger,
        'bgColor': const Color(0xFFFFEBEE),
        'title': 'You Deserve Support',
        'subtitle': 'High Concern',
        'message':
            'Your responses suggest you may be experiencing significant distress. Please know that you\'re not alone, and help is available. We strongly encourage you to book a session with a counselor — they are here to support you without judgment.',
        'tag': '⚠️ Counseling Strongly Recommended',
        'showBooking': true,
      },
    };

    final cfg = config[result]!;
    final color = cfg['color'] as Color;
    final showBooking = cfg['showBooking'] as bool;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Result icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: cfg['bgColor'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(cfg['icon'] as IconData, color: color, size: 52),
          ),
          const SizedBox(height: 14),

          Text(
            cfg['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),

          // Status tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              cfg['tag'] as String,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Your Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$score / $maxScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / maxScore,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score <= 9
                          ? Colors.green.shade300
                          : score <= 18
                              ? Colors.orange.shade300
                              : Colors.red.shade300,
                    ),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 — Healthy',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10)),
                    Text('30 — High Concern',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score legend
          Row(
            children: [
              _ScoreBand(label: '0–9', desc: 'Healthy', color: Colors.green),
              const SizedBox(width: 8),
              _ScoreBand(
                  label: '10–18',
                  desc: 'Mild Concern',
                  color: AppColors.warning),
              const SizedBox(width: 8),
              _ScoreBand(
                  label: '19–30',
                  desc: 'High Concern',
                  color: AppColors.danger),
            ],
          ),
          const SizedBox(height: 16),

          // Message box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              cfg['message'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13.5,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Book counselor button
          if (showBooking) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCounselorAlert(result),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text(
                  'Book a Counselor',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Retake
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Retake Assessment',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkGreen,
                side: const BorderSide(color: AppColors.darkGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Score band widget ────────────────────────────────────────
class _ScoreBand extends StatelessWidget {
  final String label;
  final String desc;
  final Color color;

  const _ScoreBand(
      {required this.label, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result levels ────────────────────────────────────────────
enum _QuizResult { healthy, mildConcern, highConcern }
