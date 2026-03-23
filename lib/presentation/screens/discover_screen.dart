import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../blocs/discover_bloc.dart';
import '../../data/models/course_model.dart';
import '../../data/models/course_progress_model.dart';
import '../../data/services/firestore_service.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoverBloc(FirestoreService())..add(LoadCourses()),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();
  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  static const Color teal = Color(0xFF00D4D4);
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Digital Skills',
    'Sign Language',
    'Braille',
    'Vocational',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B1E) : const Color(0xFFF5F5F5);

    return BlocListener<DiscoverBloc, DiscoverState>(
      listener: (context, state) {
        if (state is DiscoverError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            _buildCategoryChips(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 4,
        right: 4,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Inclusive Learning Platform',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (q) => context.read<DiscoverBloc>().add(SearchCourses(q)),
        decoration: InputDecoration(
          hintText: 'Search courses...',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DiscoverBloc>().add(SearchCourses(''));
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        final selected =
            state is DiscoverLoaded ? state.selectedCategory : 'All';
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isSelected = _categories[i] == selected;
              return ChoiceChip(
                label: Text(_categories[i]),
                selected: isSelected,
                onSelected: (_) => context.read<DiscoverBloc>().add(
                      FilterCourses(_categories[i]),
                    ),
                selectedColor: teal,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? teal : Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        if (state is DiscoverLoading) {
          return const Center(child: CircularProgressIndicator(color: teal));
        }
        if (state is DiscoverLoaded) {
          if (state.filteredCourses.isEmpty) return _buildEmptyState();
          final isWide = MediaQuery.of(context).size.width >= 600;
          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: state.filteredCourses.length,
              itemBuilder: (context, i) => _AnimatedCourseCard(
                course: state.filteredCourses[i],
                progress: state.progressMap[state.filteredCourses[i].id],
                index: i,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            itemCount: state.filteredCourses.length,
            itemBuilder: (context, i) => _AnimatedCourseCard(
              course: state.filteredCourses[i],
              progress: state.progressMap[state.filteredCourses[i].id],
              index: i,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCourseCard extends StatefulWidget {
  final Course course;
  final CourseProgress? progress;
  final int index;
  const _AnimatedCourseCard({
    required this.course,
    this.progress,
    required this.index,
  });
  @override
  State<_AnimatedCourseCard> createState() => _AnimatedCourseCardState();
}

class _AnimatedCourseCardState extends State<_AnimatedCourseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _CourseCard(course: widget.course, progress: widget.progress),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final CourseProgress? progress;
  const _CourseCard({required this.course, this.progress});
  static const Color teal = Color(0xFF00D4D4);

  IconData _iconFromName(String name) {
    switch (name) {
      case 'laptop_mac':
        return Icons.laptop_mac;
      case 'sign_language':
        return Icons.sign_language;
      case 'accessibility':
        return Icons.accessibility;
      case 'cut':
        return Icons.cut;
      case 'computer':
        return Icons.computer;
      case 'record_voice_over':
        return Icons.record_voice_over;
      default:
        return Icons.school;
    }
  }

  void _shareCourse(BuildContext context) {
    Share.share(
      'Check out this course on Inclusive Learning Platform!\n\n'
      '${course.title}\n'
      '${course.module} • ${course.duration}\n\n'
      '${course.description}',
      subject: course.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressVal = progress?.progress ?? 0.0;
    final isBookmarked = progress?.isBookmarked ?? false;
    final isCompleted = progressVal >= 1.0;
    final hasStarted = progressVal > 0.0 && progressVal < 1.0;
    final iconColor = Color(course.iconColorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCourseDialog(context, progressVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: iconColor.withValues(alpha: 0.2),
                      child: Icon(
                        _iconFromName(course.iconName),
                        size: 28,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
                if (course.isNew)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: _badge('NEW', teal, Colors.black),
                  ),
                if (isCompleted)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: _badge('DONE', Colors.green, Colors.white),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.module,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: teal,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            course.duration,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(course.category),
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: teal.withValues(alpha: 0.12),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                  ),
                  if (hasStarted || isCompleted) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressVal,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted ? Colors.green : teal,
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progressVal * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? Colors.green : teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionBtn(
                        icon: hasStarted
                            ? Icons.play_circle_fill
                            : isCompleted
                                ? Icons.replay
                                : Icons.play_arrow,
                        label: hasStarted
                            ? 'Continue'
                            : isCompleted
                                ? 'Replay'
                                : 'Start',
                        onTap: () => _showCourseDialog(context, progressVal),
                      ),
                      _BookmarkButton(
                        course: course,
                        isBookmarked: isBookmarked,
                      ),
                      _actionBtn(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () => _shareCourse(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: teal),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseDialog(BuildContext context, double currentProgress) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Progress: ${(currentProgress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: currentProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(teal),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mark progress:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            _ProgressSlider(
              courseId: course.id,
              initialProgress: currentProgress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pushNamed(context, '/course-completion');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Open Course'),
          ),
        ],
      ),
    );
  }
}

class _ProgressSlider extends StatefulWidget {
  final String courseId;
  final double initialProgress;
  const _ProgressSlider({
    required this.courseId,
    required this.initialProgress,
  });
  @override
  State<_ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<_ProgressSlider> {
  static const Color teal = Color(0xFF00D4D4);
  late double _val;

  @override
  void initState() {
    super.initState();
    _val = widget.initialProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: teal,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: teal,
            overlayColor: teal.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _val,
            min: 0,
            max: 1,
            divisions: 10,
            label: '${(_val * 100).round()}%',
            onChanged: (v) => setState(() => _val = v),
            onChangeEnd: (v) {
              context.read<DiscoverBloc>().add(UpdateProgress(widget.courseId, v));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Progress updated to ${(v * 100).round()}%'),
                  backgroundColor: teal,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        Text(
          '${(_val * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w700, color: teal),
        ),
      ],
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final Course course;
  final bool isBookmarked;
  const _BookmarkButton({required this.course, required this.isBookmarked});
  static const Color teal = Color(0xFF00D4D4);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<DiscoverBloc>().add(
              ToggleCourseBookmark(course.id, isCurrentlyBookmarked: isBookmarked),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBookmarked ? 'Bookmark removed' : 'Course saved!'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isBookmarked
              ? teal.withValues(alpha: 0.25)
              : teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 15,
              color: teal,
            ),
            const SizedBox(width: 4),
            Text(
              isBookmarked ? 'Saved' : 'Save',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}