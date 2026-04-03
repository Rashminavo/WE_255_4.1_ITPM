import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _backgroundController;
  late AnimationController _iconAnimationController;
  late AnimationController _pulseController;
  late AnimationController _demoController;

  // Demo states for interactive onboarding
  bool _sosDemoTriggered = false;
  bool _buddyDemoMatched = false;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.shield_outlined,
      title: "Welcome to RagSafe SL",
      description:
          "Your trusted companion for staying safe on campus. Swipe to explore our powerful features.",
      color: const Color(0xFF1D9E75),
      gradientColors: const [Color(0xFF1D9E75), Color(0xFF0F6E56)],
      demoType: DemoType.welcome,
    ),
    OnboardingItem(
      icon: Icons.warning_amber_rounded,
      title: "Emergency SOS",
      description:
          "One tap sends instant alerts to campus security when you need help.",
      color: const Color(0xFFE24B4A),
      gradientColors: const [Color(0xFFE24B4A), Color(0xFFC73E3D)],
      demoType: DemoType.sos,
    ),
    OnboardingItem(
      icon: Icons.people_outline,
      title: "Buddy System",
      description:
          "Find travel buddies in real-time. Never walk alone on campus.",
      color: const Color(0xFF2196F3),
      gradientColors: const [Color(0xFF2196F3), Color(0xFF1976D2)],
      demoType: DemoType.buddy,
    ),
    OnboardingItem(
      icon: Icons.psychology_outlined,
      title: "24/7 Support",
      description:
          "Connect with counselors anonymously. Your mental health matters.",
      color: const Color(0xFF9C27B0),
      gradientColors: const [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      demoType: DemoType.support,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _demoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start initial animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _iconAnimationController.forward();
    });
  }

  void _nextPage() {
    _iconAnimationController.forward(from: 0);
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToMainApp();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _goToMainApp() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(), // Routes through Auth logic automatically
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _iconAnimationController.dispose();
    _pulseController.dispose();
    _demoController.dispose();
    super.dispose();
  }

  void _triggerSOSDemo() {
    setState(() => _sosDemoTriggered = true);
    _demoController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _sosDemoTriggered = false);
      }
    });
  }

  void _triggerBuddyDemo() {
    setState(() => _buddyDemoMatched = true);
    _demoController.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _buddyDemoMatched = false);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _currentPage < _items.length
                    ? [
                        _items[_currentPage].gradientColors[0],
                        _items[_currentPage].gradientColors[1],
                      ]
                    : [Colors.white, Colors.white],
                stops: [
                  0.0,
                  1.0,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // Skip button with animated position
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_currentPage + 1} / ${_items.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView with parallax effect
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _iconAnimationController.forward(from: 0);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_items[index], index);
                  },
                ),
              ),

              // Enhanced dots indicator
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentPage == index ? 40 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // Main button with gradient
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _nextPage,
                          borderRadius: BorderRadius.circular(30),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _items.length - 1
                                      ? "Get Started"
                                      : "Continue",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _items[_currentPage].color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == _items.length - 1
                                      ? Icons.arrow_forward
                                      : Icons.arrow_right_alt,
                                  color: _items[_currentPage].color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _goToLogin,
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
            }

            return Center(
              child: SizedBox(
                height: constraints.maxHeight * value,
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon with multiple layers
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _iconAnimationController,
                      curve: Curves.elasticOut,
                    ),
                    child: _buildAnimatedIcon(item),
                  ),

                  const SizedBox(height: 40),

                  // Title with slide effect
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _iconAnimationController,
                      curve:
                          const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _iconAnimationController,
                        curve: const Interval(0.2, 1.0),
                      ),
                      child: Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description with fade and slide
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.8),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _iconAnimationController,
                      curve:
                          const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _iconAnimationController,
                        curve: const Interval(0.4, 1.0),
                      ),
                      child: Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Interactive Demo Widget
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _iconAnimationController,
                      curve:
                          const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                    )),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _iconAnimationController,
                        curve: const Interval(0.5, 1.0),
                      ),
                      child: _buildDemoWidget(item),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemoWidget(OnboardingItem item) {
    switch (item.demoType) {
      case DemoType.welcome:
        return _buildWelcomeDemo(item);
      case DemoType.sos:
        return _buildSOSDemo(item);
      case DemoType.buddy:
        return _buildBuddyDemo(item);
      case DemoType.support:
        return _buildSupportDemo(item);
    }
  }

  Widget _buildWelcomeDemo(OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _featureIcon(
                  Icons.warning_amber_rounded, const Color(0xFFE24B4A)),
              const SizedBox(width: 12),
              _featureIcon(Icons.people_outline, const Color(0xFF2196F3)),
              const SizedBox(width: 12),
              _featureIcon(Icons.report_outlined, const Color(0xFFFF9800)),
              const SizedBox(width: 12),
              _featureIcon(Icons.map_outlined, const Color(0xFF9C27B0)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Swipe to explore features →",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildSOSDemo(OnboardingItem item) {
    return GestureDetector(
      onTap: _triggerSOSDemo,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _sosDemoTriggered
              ? const Color(0xFFE24B4A).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _sosDemoTriggered
                ? const Color(0xFFE24B4A)
                : Colors.white.withValues(alpha: 0.3),
            width: _sosDemoTriggered ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE24B4A).withValues(
                      alpha: _sosDemoTriggered
                          ? 0.8
                          : 0.3 + (_pulseController.value * 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE24B4A).withValues(
                          alpha: _sosDemoTriggered
                              ? 0.8
                              : 0.3 + (_pulseController.value * 0.4),
                        ),
                        blurRadius: _sosDemoTriggered
                            ? 40
                            : 20 + (_pulseController.value * 20),
                        spreadRadius: _sosDemoTriggered
                            ? 10
                            : 2 + (_pulseController.value * 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _sosDemoTriggered ? "🚨 ALERT SENT!" : "Tap to try SOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: _sosDemoTriggered ? 18 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_sosDemoTriggered)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Security notified!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyDemo(OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          if (!_buddyDemoMatched) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar("You", Icons.person, const Color(0xFF2196F3)),
                const SizedBox(width: 20),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2196F3)
                            .withValues(alpha: 0.2 + (_pulseController.value * 0.3)),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                _buildAvatar("?", Icons.help_outline, Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _triggerBuddyDemo,
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text("Find a Buddy"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar("You", Icons.person, const Color(0xFF2196F3)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                _buildAvatar("Kavindu", Icons.person, const Color(0xFF2196F3)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "✅ Buddy Matched!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Heading to Library together",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportDemo(OnboardingItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounselorAvatar("Dr. Priya", true),
              const SizedBox(width: 16),
              _buildCounselorAvatar("Mr. Kasun", true),
              const SizedBox(width: 16),
              _buildCounselorAvatar("Ms. Dilini", false),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  "Anonymous Chat Available",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _buildCounselorAvatar(String name, bool isAvailable) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00BCD4).withValues(alpha: 0.3),
                    const Color(0xFF00BCD4).withValues(alpha: 0.5),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00BCD4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (isAvailable)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon(OnboardingItem item) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            Transform.rotate(
              angle: _backgroundController.value * 2 * math.pi,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Middle pulsing circle
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            // Counter-rotating inner ring
            Transform.rotate(
              angle: -_backgroundController.value * 2 * math.pi,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Floating dots around the icon
            ...List.generate(8, (index) {
              final angle = (index * 45) * (math.pi / 180);
              final radius = 90.0;
              return Transform.translate(
                offset: Offset(
                  math.cos(angle + _backgroundController.value * 2 * math.pi) *
                      radius,
                  math.sin(angle + _backgroundController.value * 2 * math.pi) *
                      radius,
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            // Main icon container
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 60,
                color: item.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Demo types for interactive onboarding
enum DemoType {
  welcome,
  sos,
  buddy,
  support,
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradientColors;
  final DemoType demoType;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradientColors,
    required this.demoType,
  });
}

// Custom painter for map grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw some random "streets"
    final streetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.3, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.5),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
