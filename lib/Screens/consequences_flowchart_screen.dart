import 'package:flutter/material.dart';
import 'app_colors.dart';

class ConsequencesFlowchartScreen extends StatefulWidget {
  const ConsequencesFlowchartScreen({super.key});

  @override
  State<ConsequencesFlowchartScreen> createState() =>
      _ConsequencesFlowchartScreenState();
}

class _ConsequencesFlowchartScreenState
    extends State<ConsequencesFlowchartScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _hasResult = false;
  String _errorMessage = '';

  // Simulated complaint data fetched from backend
  // In production, replace _fetchComplaint() with a real API call
  late _ComplaintData _complaint;

  // ── Simulated database of complaints ────────────────────────
  // Replace this with your actual backend/database call
  static final Map<String, _ComplaintData> _mockDatabase = {
    'CMP-001': _ComplaintData(
      id: 'CMP-001',
      type: 'Academic',
      category: 'Physical Ragging',
      filedDate: '12 Jan 2025',
      currentStep: 4,
      lastUpdated: '18 Jan 2025',
      assignedOfficer: 'Prof. R. Sharma (Anti-Ragging Cell)',
      updates: [
        _StepUpdate(
            step: 0,
            date: '12 Jan 2025',
            note: 'Complaint received and registered by Anti-Ragging Cell.'),
        _StepUpdate(
            step: 1,
            date: '13 Jan 2025',
            note: 'Acknowledgement sent to complainant via email and SMS.'),
        _StepUpdate(
            step: 2,
            date: '14 Jan 2025',
            note:
                'Inquiry committee of 3 members formed. Investigation underway.'),
        _StepUpdate(
            step: 3,
            date: '16 Jan 2025',
            note:
                'Accused party formally notified and summoned for questioning on 20 Jan 2025.'),
        _StepUpdate(
            step: 4,
            date: '18 Jan 2025',
            note:
                'Formal hearing scheduled for 22 Jan 2025. Both parties to present statements.'),
      ],
    ),
    'CMP-002': _ComplaintData(
      id: 'CMP-002',
      type: 'Legal',
      category: 'Cyber Ragging',
      filedDate: '05 Feb 2025',
      currentStep: 2,
      lastUpdated: '10 Feb 2025',
      assignedOfficer: 'SI Pradeep Kumar (City Police)',
      updates: [
        _StepUpdate(
            step: 0,
            date: '05 Feb 2025',
            note: 'FIR No. 112/2025 registered at City Police Station.'),
        _StepUpdate(
            step: 1,
            date: '07 Feb 2025',
            note:
                'Digital forensics team assigned. Screenshots and messages collected as evidence.'),
        _StepUpdate(
            step: 2,
            date: '10 Feb 2025',
            note:
                'Accused summoned for questioning. Digital evidence being analyzed.'),
      ],
    ),
    'CMP-003': _ComplaintData(
      id: 'CMP-003',
      type: 'Academic',
      category: 'Verbal Abuse',
      filedDate: '20 Dec 2024',
      currentStep: 7,
      lastUpdated: '10 Jan 2025',
      assignedOfficer: 'Dr. A. Menon (Dean of Students)',
      updates: [
        _StepUpdate(
            step: 0,
            date: '20 Dec 2024',
            note: 'Complaint received and registered.'),
        _StepUpdate(
            step: 1,
            date: '21 Dec 2024',
            note: 'Acknowledgement sent to complainant.'),
        _StepUpdate(
            step: 2,
            date: '22 Dec 2024',
            note: 'Inquiry committee formed. Investigation began.'),
        _StepUpdate(
            step: 3,
            date: '24 Dec 2024',
            note: 'Accused notified and summoned.'),
        _StepUpdate(
            step: 4,
            date: '27 Dec 2024',
            note: 'Hearing conducted. Both parties gave statements.'),
        _StepUpdate(
            step: 5,
            date: '30 Dec 2024',
            note: 'Committee found complaint verified. Accused found guilty.'),
        _StepUpdate(
            step: 6,
            date: '04 Jan 2025',
            note: 'Accused suspended for 1 semester. Scholarship revoked.'),
        _StepUpdate(
            step: 7,
            date: '10 Jan 2025',
            note: 'Case closed. Counseling support offered to complainant.'),
      ],
    ),
  };

  // ── Steps for Academic complaints ───────────────────────────
  static const List<Map<String, dynamic>> _academicSteps = [
    {
      'title': 'Complaint Filed',
      'icon': Icons.assignment_turned_in_rounded,
      'color': Color(0xFF2D6A4F)
    },
    {
      'title': 'Acknowledgement Sent',
      'icon': Icons.mark_email_read_rounded,
      'color': Color(0xFF40916C)
    },
    {
      'title': 'Investigation Initiated',
      'icon': Icons.manage_search_rounded,
      'color': Color(0xFF52B788)
    },
    {
      'title': 'Accused Notified',
      'icon': Icons.notification_important_rounded,
      'color': Color(0xFFE07B39)
    },
    {
      'title': 'Hearing in Progress',
      'icon': Icons.record_voice_over_rounded,
      'color': Color(0xFFD4A853)
    },
    {
      'title': 'Decision Made',
      'icon': Icons.gavel_rounded,
      'color': Color(0xFFB5362A)
    },
    {
      'title': 'Action Taken',
      'icon': Icons.shield_rounded,
      'color': Color(0xFF1B4332)
    },
    {
      'title': 'Case Closed',
      'icon': Icons.task_alt_rounded,
      'color': Color(0xFF2D6A4F)
    },
  ];

  // ── Steps for Legal complaints ───────────────────────────────
  static const List<Map<String, dynamic>> _legalSteps = [
    {
      'title': 'FIR Filed',
      'icon': Icons.local_police_rounded,
      'color': Color(0xFF2D6A4F)
    },
    {
      'title': 'Police Investigation',
      'icon': Icons.search_rounded,
      'color': Color(0xFF40916C)
    },
    {
      'title': 'Accused Summoned',
      'icon': Icons.person_off_rounded,
      'color': Color(0xFFE07B39)
    },
    {
      'title': 'Charge Sheet Filed',
      'icon': Icons.folder_open_rounded,
      'color': Color(0xFFD4A853)
    },
    {
      'title': 'Court Hearing',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF7B2D8B)
    },
    {
      'title': 'Verdict Delivered',
      'icon': Icons.gavel_rounded,
      'color': Color(0xFFB5362A)
    },
    {
      'title': 'Sentence / Appeal',
      'icon': Icons.verified_rounded,
      'color': Color(0xFF1B4332)
    },
    {
      'title': 'Case Resolved',
      'icon': Icons.task_alt_rounded,
      'color': Color(0xFF2D6A4F)
    },
  ];

  List<Map<String, dynamic>> get _steps =>
      _complaint.type == 'Academic' ? _academicSteps : _legalSteps;

  // ── Fetch complaint ──────────────────────────────────────────
  Future<void> _fetchComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasResult = false;
      _errorMessage = '';
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final id = _idController.text.trim().toUpperCase();
    final data = _mockDatabase[id];

    setState(() {
      _isLoading = false;
      if (data != null) {
        _complaint = data;
        _hasResult = true;
      } else {
        _errorMessage =
            'No complaint found with ID "$id". Please check your Complaint ID and try again.';
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Track My Complaint',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_hasResult)
            TextButton(
              onPressed: () => setState(() {
                _hasResult = false;
                _idController.clear();
                _errorMessage = '';
              }),
              child: const Text('Search',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _hasResult ? _buildTracker() : _buildSearchScreen(),
    );
  }

  // ── Search Screen ────────────────────────────────────────────
  Widget _buildSearchScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Illustration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded,
                color: AppColors.darkGreen, size: 52),
          ),
          const SizedBox(height: 20),

          const Text(
            'Track Your Complaint',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your Complaint ID to see the current status and actions taken by authorities.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMid,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),

          // Search form
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _idController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1.5,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. CMP-001',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.darkGreen),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.darkGreen, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.danger, width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your Complaint ID';
                    }
                    if (val.trim().length < 3) {
                      return 'Complaint ID is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchComplaint,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.track_changes_rounded),
                    label: Text(
                      _isLoading ? 'Searching...' : 'Track Complaint',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.darkGreen.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),

          // Try demo IDs hint
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.darkGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Demo Complaint IDs to try:',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _demoIdChip('CMP-001', 'Academic • In Progress'),
                const SizedBox(height: 6),
                _demoIdChip('CMP-002', 'Legal • In Progress'),
                const SizedBox(height: 6),
                _demoIdChip('CMP-003', 'Academic • Closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoIdChip(String id, String label) {
    return GestureDetector(
      onTap: () {
        _idController.text = id;
        _fetchComplaint();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_rounded,
                color: AppColors.darkGreen, size: 16),
            const SizedBox(width: 8),
            Text(
              id,
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '— $label',
              style: const TextStyle(
                color: AppColors.textMid,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMid, size: 12),
          ],
        ),
      ),
    );
  }

  // ── Complaint Tracker ────────────────────────────────────────
  Widget _buildTracker() {
    final steps = _steps;
    final currentStep = _complaint.currentStep;
    final progress = (currentStep + 1) / steps.length;
    final isClosed = currentStep == steps.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Complaint summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _complaint.id,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${_complaint.type} • ${_complaint.category}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isClosed
                            ? Colors.green.withValues(alpha: 0.25)
                            : Colors.orange.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isClosed ? 'Closed' : 'Active',
                        style: TextStyle(
                          color: isClosed
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF74C69D)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${currentStep + 1} of ${steps.length}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Meta info row
          Row(
            children: [
              _metaChip(Icons.calendar_today_rounded,
                  'Filed: ${_complaint.filedDate}'),
              const SizedBox(width: 8),
              _metaChip(
                  Icons.update_rounded, 'Updated: ${_complaint.lastUpdated}'),
            ],
          ),
          const SizedBox(height: 8),
          _metaChip(
              Icons.person_rounded, 'Officer: ${_complaint.assignedOfficer}',
              fullWidth: true),
          const SizedBox(height: 24),

          const Text(
            'Complaint Progress',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // Timeline
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isDone = i < currentStep;
            final isCurrent = i == currentStep;
            final isPending = i > currentStep;

            // Find the update for this step if it exists
            final update =
                _complaint.updates.where((u) => u.step == i).isNotEmpty
                    ? _complaint.updates.firstWhere((u) => u.step == i)
                    : null;

            return _buildTimelineStep(
              step: step,
              index: i,
              isDone: isDone,
              isCurrent: isCurrent,
              isPending: isPending,
              isLast: i == steps.length - 1,
              update: update,
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Timeline step ────────────────────────────────────────────
  Widget _buildTimelineStep({
    required Map<String, dynamic> step,
    required int index,
    required bool isDone,
    required bool isCurrent,
    required bool isPending,
    required bool isLast,
    required _StepUpdate? update,
  }) {
    final dotColor = isDone
        ? AppColors.lightGreen
        : isCurrent
            ? step['color'] as Color
            : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + line
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : step['icon'] as IconData,
                    color: isPending ? Colors.grey.shade400 : Colors.white,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      color: isDone
                          ? AppColors.lightGreen.withValues(alpha: 0.5)
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step['title'] as String,
                          style: TextStyle(
                            color: isPending
                                ? Colors.grey.shade400
                                : AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      if (isDone) _statusBadge('Done', Colors.green),
                      if (isCurrent)
                        _statusBadge('Active', step['color'] as Color),
                      if (isPending) _statusBadge('Pending', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Authority update box — only if update exists
                  if (update != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.withValues(alpha: 0.05)
                            : (step['color'] as Color).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDone
                              ? Colors.green.withValues(alpha: 0.2)
                              : (step['color'] as Color).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: isDone
                                    ? Colors.green
                                    : step['color'] as Color,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Authority Update',
                                style: TextStyle(
                                  color: isDone
                                      ? Colors.green
                                      : step['color'] as Color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                update.date,
                                style: const TextStyle(
                                  color: AppColors.textMid,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            update.note,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isPending) ...[
                    // Pending placeholder
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_empty_rounded,
                              color: Colors.grey.shade400, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Awaiting action from authorities',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.darkGreen, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMid,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────
class _ComplaintData {
  final String id;
  final String type;
  final String category;
  final String filedDate;
  final int currentStep;
  final String lastUpdated;
  final String assignedOfficer;
  final List<_StepUpdate> updates;

  _ComplaintData({
    required this.id,
    required this.type,
    required this.category,
    required this.filedDate,
    required this.currentStep,
    required this.lastUpdated,
    required this.assignedOfficer,
    required this.updates,
  });
}

class _StepUpdate {
  final int step;
  final String date;
  final String note;

  _StepUpdate({
    required this.step,
    required this.date,
    required this.note,
  });
}
