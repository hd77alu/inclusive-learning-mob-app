import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/skills_bloc.dart';
import '/data/services/firestore_service.dart';
import '/data/models/skill_model.dart';
import '/presentation/widgets/accessible_widgets.dart';
import '/presentation/widgets/accessibility_provider.dart';

class MySkillsScreen extends StatefulWidget {
  const MySkillsScreen({super.key});

  @override
  State<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends State<MySkillsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _teal = Color(0xFF00D4D4);
  static const Color _bg = Color(0xFFF5F5F5);

  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Maps skill level strings to display config
  static const Map<String, _LevelConfig> _levelConfig = {
    'Beginner': _LevelConfig(
      color: Color(0xFF4CAF50),
      bg: Color(0xFFE8F5E9),
      progress: 0.25,
      icon: Icons.emoji_nature_outlined,
    ),
    'Intermediate': _LevelConfig(
      color: Color(0xFF2196F3),
      bg: Color(0xFFE3F2FD),
      progress: 0.55,
      icon: Icons.trending_up_rounded,
    ),
    'Advanced': _LevelConfig(
      color: Color(0xFFFF9800),
      bg: Color(0xFFFFF3E0),
      progress: 0.80,
      icon: Icons.local_fire_department_outlined,
    ),
    'Expert': _LevelConfig(
      color: Color(0xFF9C27B0),
      bg: Color(0xFFF3E5F5),
      progress: 1.0,
      icon: Icons.workspace_premium_outlined,
    ),
  };

  static const List<String> _levelOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B1E) : _bg;

    return BlocProvider(
      create: (_) => SkillsBloc(FirestoreService())..add(LoadSkills()),
      child: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: BlocConsumer<SkillsBloc, SkillsState>(
                      listener: (blocCtx, state) {
                        if (state is SkillsError) {
                          ScaffoldMessenger.of(blocCtx).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      },
                      builder: (blocCtx, state) {
                        if (state is SkillsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: _teal,
                            ),
                          );
                        }

                        if (state is SkillsLoaded) {
                          return _buildLoaded(blocCtx, state.skills);
                        }

                        return _buildEmpty(ctx);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFAB(ctx),
        ),
      ),
    );
  }

  // ─── Header (matches ProfileScreen style) ───────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 4,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Go back',
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AccessibleText(
                  'Inclusive Learning Platform',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                AccessibleText(
                  'My Skills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Spacer to balance the back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ─── Loaded state ────────────────────────────────────────────────────────
  Widget _buildLoaded(BuildContext blocCtx, List<Skill> skills) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryBanner(skills)),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: AccessibleText(
              'SKILL PORTFOLIO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
        if (skills.isEmpty)
          SliverFillRemaining(child: _buildEmpty(blocCtx))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => _buildSkillCard(blocCtx, skills[index]),
              childCount: skills.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ─── Summary banner ──────────────────────────────────────────────────────
  Widget _buildSummaryBanner(List<Skill> skills) {
    final total = skills.length;
    final byLevel = <String, int>{};
    for (final s in skills) {
      byLevel[s.level] = (byLevel[s.level] ?? 0) + 1;
    }
    final topLevel = byLevel.entries.isEmpty
        ? '—'
        : (byLevel.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryStat(
            icon: Icons.auto_awesome_rounded,
            label: 'Total Skills',
            value: '$total',
          ),
          _buildDivider(),
          _buildSummaryStat(
            icon: Icons.emoji_events_outlined,
            label: 'Top Level',
            value: topLevel,
          ),
          _buildDivider(),
          _buildSummaryStat(
            icon: Icons.local_fire_department_outlined,
            label: 'Expert',
            value: '${byLevel['Expert'] ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Semantics(
        label: '$value $label',
        hint: 'Skills summary statistics',
        child: Column(
          children: [
            Icon(icon, color: _teal, size: 20),
            const SizedBox(height: 6),
            AccessibleText(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            AccessibleText(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // ─── Individual skill card ───────────────────────────────────────────────
  Widget _buildSkillCard(BuildContext blocCtx, Skill skill) {
    final cfg = _levelConfig[skill.level] ??
        const _LevelConfig(
          color: Color(0xFF00D4D4),
          bg: Color(0xFFE0FAFA),
          progress: 0.3,
          icon: Icons.star_outline,
        );

    return Semantics(
      label: '${skill.name}, ${skill.level} level, ${(cfg.progress * 100).round()} percent proficiency',
      hint: 'Skill card with edit and delete options',
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Level icon badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cfg.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cfg.icon, color: cfg.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AccessibleText(
                          skill.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cfg.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AccessibleText(
                            skill.level.isNotEmpty ? skill.level : 'Unknown',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cfg.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Semantics(
                    button: true,
                    label: 'Edit ${skill.name}',
                    hint: 'Double tap to edit skill',
                    child: IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: Colors.grey.shade500, size: 20),
                      tooltip: 'Edit skill',
                      onPressed: () => _showSkillDialog(blocCtx, skill: skill),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Delete ${skill.name}',
                    hint: 'Double tap to remove skill',
                    child: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade300, size: 20),
                      tooltip: 'Delete skill',
                      onPressed: () =>
                          _confirmDelete(blocCtx, skill),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Semantics(
                label: 'Progress ${(cfg.progress * 100).round()} percent',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cfg.progress,
                    minHeight: 6,
                    backgroundColor: cfg.bg,
                    valueColor: AlwaysStoppedAnimation<Color>(cfg.color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext ctx) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                size: 40,
                color: _teal,
              ),
            ),
            const SizedBox(height: 12),
            const AccessibleText(
              'No skills added yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            AccessibleText(
              'Add your first skill to start building your portfolio.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext ctx) {
    final a11y = AccessibilityProvider.of(context);
    return BlocBuilder<SkillsBloc, SkillsState>(
      builder: (blocCtx, _) => Semantics(
        button: true,
        label: 'Add new skill',
        hint: 'Double tap to add a skill to your portfolio',
        child: FloatingActionButton.extended(
          onPressed: () => _showSkillDialog(blocCtx),
          backgroundColor: _teal,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Add Skill',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * a11y.fontSizeMultiplier),
          ),
        ),
      ),
    );
  }

  // ─── Add / Edit dialog ───────────────────────────────────────────────────
  void _showSkillDialog(BuildContext blocCtx, {Skill? skill}) {
    final nameCtrl = TextEditingController(text: skill?.name ?? '');
    String selectedLevel = skill?.level ?? _levelOptions.first;
    // Ensure the current value is valid
    if (!_levelOptions.contains(selectedLevel)) {
      selectedLevel = _levelOptions.first;
    }
    final a11y = AccessibilityProvider.of(context);

    showDialog(
      context: blocCtx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (stCtx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            skill == null ? 'Add Skill' : 'Edit Skill',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skill name field
              Semantics(
                textField: true,
                label: 'Skill name',
                hint: 'Enter skill name, for example Flutter or Sign Language',
                child: TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Skill Name',
                    hintText: 'e.g. Flutter, Sign Language',
                    prefixIcon: const Icon(Icons.code_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _teal, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Level picker
              const Text(
                'Proficiency Level',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _levelOptions.map((level) {
                  final cfg = _levelConfig[level]!;
                  final isSelected = selectedLevel == level;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: '$level proficiency level',
                    hint: isSelected ? 'Currently selected' : 'Tap to select',
                    child: GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedLevel = level),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? cfg.color : cfg.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? cfg.color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 13 * a11y.fontSizeMultiplier,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : cfg.color,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final newSkill = Skill(
                  id: skill?.id ?? '',
                  name: name,
                  level: selectedLevel,
                );

                if (skill == null) {
                  blocCtx.read<SkillsBloc>().add(AddSkill(newSkill));
                  ScaffoldMessenger.of(blocCtx).showSnackBar(
                    SnackBar(
                      content: Text('$name added to your portfolio!'),
                      backgroundColor: _teal,
                    ),
                  );
                } else {
                  blocCtx.read<SkillsBloc>().add(UpdateSkill(newSkill));
                  ScaffoldMessenger.of(blocCtx).showSnackBar(
                    const SnackBar(
                      content: Text('Skill updated successfully'),
                      backgroundColor: _teal,
                    ),
                  );
                }
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                skill == null ? 'Add Skill' : 'Save Changes',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete confirmation ─────────────────────────────────────────────────
  void _confirmDelete(BuildContext blocCtx, Skill skill) {
    showDialog(
      context: blocCtx,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Skill',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to remove "${skill.name}" from your portfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              blocCtx.read<SkillsBloc>().add(DeleteSkill(skill.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(blocCtx).showSnackBar(
                SnackBar(
                  content: Text('"${skill.name}" removed'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Level display config ──────────────────────────────────────────────────
class _LevelConfig {
  final Color color;
  final Color bg;
  final double progress;
  final IconData icon;

  const _LevelConfig({
    required this.color,
    required this.bg,
    required this.progress,
    required this.icon,
  });
}