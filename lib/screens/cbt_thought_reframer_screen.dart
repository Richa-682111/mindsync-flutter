import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';
import '../utils/app_theme.dart';

class CBTThoughtReframerScreen extends StatefulWidget {
  const CBTThoughtReframerScreen({super.key});

  @override
  State<CBTThoughtReframerScreen> createState() =>
      _CBTThoughtReframerScreenState();
}

class _CBTThoughtReframerScreenState extends State<CBTThoughtReframerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _thoughtCtrl = TextEditingController();
  bool _isLoading = false;
  String? _detectedCategory;
  String? _reframedThought;

  late final AnimationController _releaseAnimCtrl;
  late final Animation<double> _lanternRise;
  late final Animation<double> _lanternScale;
  late final Animation<double> _lanternOpacity;
  late final Animation<double> _labelOpacity;

  @override
  void initState() {
    super.initState();
    _releaseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _lanternRise = Tween<double>(begin: 0.0, end: -260.0).animate(
      CurvedAnimation(parent: _releaseAnimCtrl, curve: Curves.easeInOutCubic),
    );
    _lanternScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _releaseAnimCtrl, curve: Curves.easeOutCubic),
    );
    _lanternOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _releaseAnimCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );
    _labelOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _releaseAnimCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _thoughtCtrl.dispose();
    _releaseAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _reframeThought() async {
    final thought = _thoughtCtrl.text.trim();
    if (thought.isEmpty) return;

    setState(() {
      _isLoading = true;
      _detectedCategory = null;
      _reframedThought = null;
    });

    try {
      final analysis = await AiService.analyzeThought(thought: thought);
      if (!mounted) return;

      setState(() {
        _detectedCategory = analysis?.category ?? 'Negative Thought Pattern';
        _reframedThought = analysis?.reframedThought ??
            'You are having a hard moment, not a permanent failure. Take one small step and keep going.';
      });

      await _releaseAnimCtrl.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detectedCategory = 'Negative Thought Pattern';
        _reframedThought =
            'This thought feels heavy right now, but it does not define you. You can handle this one step at a time.';
      });
      await _releaseAnimCtrl.forward(from: 0);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _reframedThought != null;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Thought Reframer'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share your thought. I will reframe it and help you release it.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _thoughtCtrl,
                  maxLines: 5,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your negative thought here...',
                    hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _thoughtCtrl.text.trim().isEmpty
                      ? null
                      : _reframeThought,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Reframe Thought',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 220,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _releaseAnimCtrl,
                    builder: (_, __) {
                      return Opacity(
                        opacity: hasResult ? 1 : 0,
                        child: Transform.translate(
                          offset: Offset(0, _lanternRise.value),
                          child: Opacity(
                            opacity: _lanternOpacity.value,
                            child: Transform.scale(
                              scale: _lanternScale.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 260),
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
                                        _thoughtCtrl.text.trim(),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
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
                                          AppTheme.warmTone.withValues(
                                            alpha: 0.88,
                                          ),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: AppTheme.warmTone.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (hasResult) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Pattern: ${_detectedCategory ?? 'Negative Thought Pattern'}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _reframedThought ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          height: 1.45,
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
    );
  }
}
