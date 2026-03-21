import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/accessibility_bloc.dart';
import '../../data/services/firestore_service.dart';

class AccessibilitySetupScreen extends StatelessWidget {
  const AccessibilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccessibilityBloc(FirestoreService())..add(LoadAccessibilityPreference()),
      child: const _AccessibilitySetupView(),
    );
  }
}

class _AccessibilitySetupView extends StatelessWidget {
  const _AccessibilitySetupView();
  static const Color teal = Color(0xFF00D4D4);

  static const List<_A11yOption> _options = [
    _A11yOption(id: 'visual', icon: Icons.visibility_outlined, label: 'Visual', description: 'Screen reader, Enable large text', verified: true),
    _A11yOption(id: 'auditory', icon: Icons.hearing_outlined, label: 'Auditory', description: 'Captions, Sign Language', verified: false),
    _A11yOption(id: 'motor', icon: Icons.accessibility_new_outlined, label: 'Motor', description: 'Switch access, Voice control', verified: false),
    _A11yOption(id: 'cognitive', icon: Icons.psychology_outlined, label: 'Cognitive', description: 'Simplified UI, Focus mode', verified: false),
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });

    return BlocListener<AccessibilityBloc, AccessibilityState>(
      listener: (context, state) {
        if (state is AccessibilitySaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Accessibility preference saved!'),
            backgroundColor: teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
          Navigator.pushReplacementNamed(context, '/signup');
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
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
            width: double.infinity,
            color: teal,
            padding: const EdgeInsets.only(top: 50, bottom: 14),
            child: const Text('Inclusive Learning Platform',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black)),
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
                        _buildProgressSection(),
                        const SizedBox(height: 20),
                        _buildHeroCard(isWide),
                        const SizedBox(height: 20),
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
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 26),
          onPressed: () => Navigator.maybePop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const Expanded(
          child: Text('Accessibility Setup',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
        ),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildProgressSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Onboarding Progress', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        Text('Step 1 of 3', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const LinearProgressIndicator(
          value: 0.33,
          backgroundColor: Color(0xFFEEEEEE),
          valueColor: AlwaysStoppedAnimation<Color>(teal),
          minHeight: 5,
        ),
      ),
    ]);
  }

  Widget _buildHeroCard(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 28 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD966), Color(0xFFFFB347), Color(0xFF00D4D4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tailor Your\nExperience',
            style: TextStyle(color: Colors.black, fontSize: isWide ? 30 : 26, fontWeight: FontWeight.w900, height: 1.2)),
        const SizedBox(height: 10),
        Text("Select the options that best support your needs.\nWe'll adjust the platform to work for you.",
            style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: isWide ? 14 : 13, height: 1.5)),
      ]),
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
            : const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? teal : Colors.grey.shade200, width: isSelected ? 1.8 : 1),
          boxShadow: [BoxShadow(color: isSelected ? teal.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? teal.withValues(alpha: 0.12) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: isSelected ? teal : Colors.grey.shade500, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Flexible(child: Text(option.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isSelected ? Colors.black87 : Colors.black54))),
                  if (option.verified) ...[const SizedBox(width: 6), Icon(Icons.check_circle, color: teal, size: 15)],
                ]),
                const SizedBox(height: 3),
                Text(option.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ])),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? teal : Colors.grey.shade300, width: isSelected ? 5.5 : 1.5),
                  color: Colors.white,
                ),
              ),
            ]),
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
  final bool verified;
  const _A11yOption({required this.id, required this.icon, required this.label, required this.description, required this.verified});
}