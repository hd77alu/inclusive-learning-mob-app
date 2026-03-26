import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/accessibility_bloc.dart';
import '/presentation/widgets/accessible_widgets.dart';

class AccessibilitySetupScreen extends StatelessWidget {
  const AccessibilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccessibilitySetupView();
  }
}

class _AccessibilitySetupView extends StatelessWidget {
  const _AccessibilitySetupView();
  static const Color teal = Color(0xFF00D4D4);

  static const List<_A11yOption> _options = [
    _A11yOption(
      id: 'default',
      icon: Icons.settings_outlined,
      label: 'Default',
      description: 'Default interface with no adjustments',
      features: ['Standard text size', 'Normal touch targets', 'Full animations'],
    ),
    _A11yOption(
      id: 'visual',
      icon: Icons.visibility_outlined,
      label: 'Visual Support',
      description: 'Enhanced visibility and readability',
      features: ['Larger text (1.3x)', 'High contrast colors', 'Screen reader support'],
    ),
    _A11yOption(
      id: 'auditory',
      icon: Icons.hearing_outlined,
      label: 'Hearing Support',
      description: 'Visual alternatives for audio content',
      features: ['Video captions', 'Visual notifications', 'Sign language support'],
    ),
    _A11yOption(
      id: 'motor',
      icon: Icons.accessibility_new_outlined,
      label: 'Motor Support',
      description: 'Easier interaction and navigation',
      features: ['Larger buttons (56px)', 'Voice control ready', 'Extended touch areas'],
    ),
    _A11yOption(
      id: 'cognitive',
      icon: Icons.psychology_outlined,
      label: 'Cognitive Support',
      description: 'Simplified and focused experience',
      features: ['Reduced animations', 'Clearer text (1.15x)', 'Simplified navigation'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B1E) : Colors.white;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });

    return BlocListener<AccessibilityBloc, AccessibilityState>(
      listener: (context, state) {
        if (state is AccessibilitySaved) {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/', 
            (_) => false,
          );
        } else if (state is AccessibilityError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(children: [
          Container(
            width: double.infinity,
            color: teal,
            padding: const EdgeInsets.only(top: 50, bottom: 14),
            child: const Text('Accessibility',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
          ),
          Expanded(
            child: BlocBuilder<AccessibilityBloc, AccessibilityState>(
              builder: (context, state) {
                if (state is AccessibilityLoading) {
                  return const Center(child: CircularProgressIndicator(color: teal));
                }
                final isSaving = state is AccessibilitySaving;
                final selectedMode = state is AccessibilityLoaded ? state.effectiveMode : null;
                return SafeArea(
                  top: false,
                  child: LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        _buildStepBar(context),
                        const SizedBox(height: 20),
                        _buildCurrentModeCard(context),
                        const SizedBox(height: 20),
                        AccessibleText(
                          'Choose Your Experience',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...(_options.map((opt) => _OptionTile(
                          option: opt,
                          isSelected: selectedMode == opt.id,
                          onTap: isSaving ? null : () => context.read<AccessibilityBloc>().add(SelectAccessibilityMode(opt.id)),
                        ))),
                        const SizedBox(height: 12),
                        _buildContinueButton(context, selectedMode, isSaving),
                        const SizedBox(height: 32),
                      ]),
                    );
                  }),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStepBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 26),
          onPressed: () => Navigator.maybePop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const Expanded(
          child: Text('Customize Your Experience',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildCurrentModeCard(BuildContext context) {
    return BlocBuilder<AccessibilityBloc, AccessibilityState>(
      builder: (context, state) {
        final currentMode = state.service.mode;
        final currentOption = _options.firstWhere(
          (opt) => opt.id == currentMode,
          orElse: () => _options[0],
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: teal.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(currentOption.icon, color: teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AccessibleText(
                          'Current Mode',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AccessibleText(
                          currentOption.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...currentOption.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AccessibleText(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(BuildContext context, String? selectedMode, bool isSaving) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: (selectedMode != null && !isSaving)
            ? () => context.read<AccessibilityBloc>().add(SaveAccessibilityPreference(selectedMode))
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: isSaving
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
            : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _A11yOption option;
  final bool isSelected;
  final VoidCallback? onTap;
  const _OptionTile({required this.option, required this.isSelected, this.onTap});
  static const Color teal = Color(0xFF00D4D4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? teal : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? teal.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? teal.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color: isSelected ? teal : Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccessibleText(
                        option.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AccessibleText(
                        option.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? teal : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: Colors.white,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _A11yOption {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  final List<String> features;
  
  const _A11yOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.features,
  });
}
