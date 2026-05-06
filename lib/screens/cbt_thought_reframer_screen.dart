import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import '../utils/app_theme.dart';
import '../utils/cbt_data.dart';

enum _ReframingPhase {
  inputThought,
  selectDistortion,
  readResponse,
  reframeThought,
  releaseAnimation,
}

class CBTThoughtReframerScreen extends StatefulWidget {
  const CBTThoughtReframerScreen({super.key});

  @override
  State<CBTThoughtReframerScreen> createState() =>
      _CBTThoughtReframerScreenState();
}

class _CBTThoughtReframerScreenState extends State<CBTThoughtReframerScreen>
    with TickerProviderStateMixin {
  _ReframingPhase _phase = _ReframingPhase.inputThought;

  final TextEditingController _thoughtCtrl = TextEditingController();
  final TextEditingController _reframeCtrl = TextEditingController();
  String? _selectedDistortionId;
  String _supportiveResponse = '';
  bool _isGeneratingResponse = false;

  late AnimationController _releaseAnimCtrl;
  late Animation<double> _lanternRise;
  late Animation<double> _lanternScale;
  late Animation<double> _lanternOpacity;
  late Animation<double> _labelOpacity;

  void _nextPhase(_ReframingPhase next) {
    FocusScope.of(context).unfocus();
    setState(() => _phase = next);
  }

  @override
  void initState() {
    super.initState();
    _releaseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _lanternRise = Tween<double>(begin: 0.0, end: -380.0).animate(
      CurvedAnimation(parent: _releaseAnimCtrl, curve: Curves.easeInOutCubic),
    );
    _lanternScale = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _releaseAnimCtrl, curve: Curves.easeOutCubic),
    );
    _lanternOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 18),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 32),
        ]).animate(
          CurvedAnimation(parent: _releaseAnimCtrl, curve: Curves.easeInOut),
        );
    _labelOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 24),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 76),
        ]).animate(
          CurvedAnimation(parent: _releaseAnimCtrl, curve: Curves.easeInOut),
        );

    _releaseAnimCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _thoughtCtrl.dispose();
    _reframeCtrl.dispose();
    _releaseAnimCtrl.dispose();
    super.dispose();
  }

  void _startReleaseAnimation() {
    _nextPhase(_ReframingPhase.releaseAnimation);
    _releaseAnimCtrl.forward(from: 0);
  }

  Future<void> _generateSupportiveResponse() async {
    final selectedId = _selectedDistortionId;
    if (selectedId == null) return;

    setState(() => _isGeneratingResponse = true);
    try {
      final distortion = CBTData.distortions.firstWhere(
        (d) => d['id'] == selectedId,
        orElse: () => const {'title': 'Negative Thought'},
      );
      final aiText = await GeminiService.generateReframedThought(
        thought: _thoughtCtrl.text.trim(),
        distortionType: distortion['title'] ?? 'Negative Thought',
      );
      _supportiveResponse = aiText ?? CBTData.getRandomResponse(selectedId);
      _nextPhase(_ReframingPhase.readResponse);
    } catch (_) {
      _supportiveResponse = CBTData.getRandomResponse(selectedId);
      _nextPhase(_ReframingPhase.readResponse);
    } finally {
      if (mounted) setState(() => _isGeneratingResponse = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Thought Reframer'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_phase != _ReframingPhase.releaseAnimation) ...[
                Text(
                  "Let's gently challenge this thought",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
              ],
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentPhase(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _ReframingPhase.inputThought:
        return _buildInputThought();
      case _ReframingPhase.selectDistortion:
        return _buildSelectDistortion();
      case _ReframingPhase.readResponse:
        return _buildReadResponse();
      case _ReframingPhase.reframeThought:
        return _buildReframeThought();
      case _ReframingPhase.releaseAnimation:
        return _buildReleaseAnimation();
    }
  }

  Widget _buildInputThought() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's bothering you right now?",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _thoughtCtrl,
            maxLines: 5,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: "e.g., I feel like I'm failing at everything...",
              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _thoughtCtrl.text.trim().isEmpty
                ? null
                : () => _nextPhase(_ReframingPhase.selectDistortion),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Next Step',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectDistortion() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What kind of thought is this?',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Our minds sometimes play tricks on us. Select the one that fits best.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: CBTData.distortions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final d = CBTData.distortions[index];
              final isSelected = _selectedDistortionId == d['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedDistortionId = d['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentSoft : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.accent : AppTheme.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(d['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['title']!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Text(
                                d['description']!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedDistortionId == null || _isGeneratingResponse
                ? null
                : _generateSupportiveResponse,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isGeneratingResponse
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Analyze Thought',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadResponse() {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppTheme.positiveSoft,
              shape: BoxShape.circle,
            ),
            child: const Text('🌿', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _supportiveResponse,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            height: 1.4,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _nextPhase(_ReframingPhase.reframeThought),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reframe My Thought',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReframeThought() {
    return Column(
      key: const ValueKey('step4'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How could you rewrite this thought more kindly?',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Original: "${_thoughtCtrl.text}"',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.positive.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.positive.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _reframeCtrl,
            maxLines: 5,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: "e.g., I made a mistake, but I'm learning...",
              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _reframeCtrl.text.trim().isEmpty
                ? null
                : _startReleaseAnimation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.positive,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Release Original Thought',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseAnimation() {
    final distortion = CBTData.distortions.firstWhere(
      (d) => d['id'] == _selectedDistortionId,
      orElse: () => const {'title': 'Thought'},
    );
    final typeLabel = distortion['title'] ?? 'Thought';
    final thoughtLabel = _thoughtCtrl.text.trim().replaceAll('\n', ' ');

    return Center(
      key: const ValueKey('step5'),
      child: AnimatedBuilder(
        animation: _releaseAnimCtrl,
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.translate(
                offset: Offset(0, _lanternRise.value),
                child: Opacity(
                  opacity: _lanternOpacity.value,
                  child: Transform.scale(
                    scale: _lanternScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 260),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Opacity(
                            opacity: _labelOpacity.value,
                            child: Text(
                              '$typeLabel - $thoughtLabel',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 68,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.warmSoft,
                                AppTheme.warmTone.withValues(alpha: 0.88),
                              ],
                            ),
                            border: Border.all(
                              color: AppTheme.warmTone.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.warmTone.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 2,
                              height: 54,
                              color: AppTheme.warmTone.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_releaseAnimCtrl.value > 0.18)
                Positioned(
                  bottom: -60,
                  child: Opacity(
                    opacity: (1.0 - _releaseAnimCtrl.value).clamp(0.0, 1.0),
                    child: Text(
                      'Thought Released.',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.positive,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
