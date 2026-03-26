import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'mentor_profile_screen.dart';
import '/blocs/mentorship_bloc.dart';
import '/data/services/firestore_service.dart';
import '/data/models/mentor_model.dart';
import '/presentation/widgets/accessible_widgets.dart';
import '/presentation/widgets/accessibility_provider.dart';

class MentorshipHubScreen extends StatefulWidget {
  const MentorshipHubScreen({super.key});

  @override
  State<MentorshipHubScreen> createState() => _MentorshipHubScreenState();
}

class _MentorshipHubScreenState extends State<MentorshipHubScreen> {
  static const Color _teal = Color(0xFF00D4D4);

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Sign Language', 'Braille'];

  @override
  void initState() {
    super.initState();
    // Auth guard — redirect only if truly not signed in
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

  List<Mentor> _filtered(List<Mentor> mentors) {
    final query = _searchController.text.toLowerCase();
    return mentors.where((m) {
      final matchesSearch = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.role.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' ||
          m.tags.any(
              (t) => t.toLowerCase().contains(_selectedFilter.toLowerCase()));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B1E) : const Color(0xFFF5F5F5);

    return BlocProvider(
      create: (_) => MentorshipBloc(FirestoreService())..add(LoadMentors()),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildMentorList()),
          ],
        ),
      ),
    );
  }

  // Teal header with back arrow, title
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 4,
        right: 4,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Go back',
            hint: 'Double tap to return to previous screen',
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const Expanded(
            child: Column(
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
                  'Mentorship Hub',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Semantics(
        textField: true,
        label: 'Search mentors',
        hint: 'Enter mentor name or specialty',
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search mentors by specialty...',
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? Semantics(
                    button: true,
                    label: 'Clear search',
                    child: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
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
      ),
    );
  }

  Widget _buildFilterChips() {
    final a11y = AccessibilityProvider.of(context);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _filters[i] == _selectedFilter;
          return Semantics(
            button: true,
            selected: selected,
            label: '${_filters[i]} filter',
            hint: selected ? 'Currently selected' : 'Tap to filter mentors',
            child: ChoiceChip(
              label: Text(_filters[i]),
              selected: selected,
              onSelected: (value) =>
                  setState(() => _selectedFilter = _filters[i]),
              selectedColor: _teal,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12 * a11y.fontSizeMultiplier,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? _teal : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMentorList() {
    return BlocConsumer<MentorshipBloc, MentorshipState>(
      listener: (context, state) {
        if (state is MentorshipError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load mentors. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MentorshipLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00D4D4)),
          );
        }

        if (state is MentorshipLoaded) {
          final mentors = _filtered(state.mentors);

          if (mentors.isEmpty) {
            return _buildEmptyState();
          }

          // Responsive: grid on wide screens, list on narrow
          final isWide = MediaQuery.of(context).size.width >= 600;

          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: mentors.length,
              itemBuilder: (context, index) => _AnimatedMentorCard(
                mentor: mentors[index],
                isBookmarked:
                    state.bookmarkedIds.contains(mentors[index].id),
                index: index,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            itemCount: mentors.length,
            itemBuilder: (context, index) => _AnimatedMentorCard(
              mentor: mentors[index],
              isBookmarked: state.bookmarkedIds.contains(mentors[index].id),
              index: index,
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
          Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No mentors available yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon!',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// Animated card wrapper — slides + fades in staggered
class _AnimatedMentorCard extends StatefulWidget {
  final Mentor mentor;
  final bool isBookmarked;
  final int index;

  const _AnimatedMentorCard({
    required this.mentor,
    required this.isBookmarked,
    required this.index,
  });

  @override
  State<_AnimatedMentorCard> createState() => _AnimatedMentorCardState();
}

class _AnimatedMentorCardState extends State<_AnimatedMentorCard>
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

    // Stagger by index
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
        child: _MentorCard(
          mentor: widget.mentor,
          isBookmarked: widget.isBookmarked,
        ),
      ),
    );
  }
}

// Mentor card
class _MentorCard extends StatelessWidget {
  final Mentor mentor;
  final bool isBookmarked;

  const _MentorCard({required this.mentor, required this.isBookmarked});

  static const Color _teal = Color(0xFF00D4D4);

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityProvider.of(context);
    final semanticLabel = '${mentor.name}, ${mentor.role}, Rating ${mentor.rating} stars${mentor.isOnline ? ", Online now" : ""}${isBookmarked ? ", Bookmarked" : ""}';
    
    return Semantics(
      button: true,
      label: semanticLabel,
      hint: 'Double tap to view mentor profile',
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorProfileScreen(mentor: mentor),
            ),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar banner with ONLINE badge
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF00D4D4),
                      child:
                          Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                ),
                if (mentor.isOnline)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Semantics(
                      label: 'Online now',
                      liveRegion: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 7, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'ONLINE NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          mentor.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Semantics(
                        label: 'Rating ${mentor.rating} stars',
                        child: Text(
                          '⭐ ${mentor.rating}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    mentor.role,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  if (mentor.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      mentor.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ],

                  if (mentor.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: mentor.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              labelStyle: TextStyle(
                                fontSize: 10 * a11y.fontSizeMultiplier,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: _teal.withValues(alpha: 0.12),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 6),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Bookmark — connected to BLoC
                      _BookmarkButton(
                          mentor: mentor, isBookmarked: isBookmarked),
                      _actionButton(
                        context: context,
                        icon: Icons.call,
                        label: 'Call',
                        onTap: () => _confirmAction(
                          context,
                          title: 'Call Mentor',
                          message: 'Do you want to call ${mentor.name}?',
                        ),
                      ),
                      _actionButton(
                        context: context,
                        icon: Icons.videocam,
                        label: 'Video',
                        onTap: () => _confirmAction(
                          context,
                          title: 'Video Session',
                          message:
                              'Start a video session with ${mentor.name}?',
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

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title request sent!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$label ${mentor.name}',
      hint: 'Double tap to $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: _teal),
              const SizedBox(width: 4),
              AccessibleText(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D4D4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bookmark button — reads and writes to BLoC
class _BookmarkButton extends StatelessWidget {
  final Mentor mentor;
  final bool isBookmarked;

  const _BookmarkButton({required this.mentor, required this.isBookmarked});

  static const Color _teal = Color(0xFF00D4D4);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isBookmarked ? 'Remove bookmark from ${mentor.name}' : 'Bookmark ${mentor.name}',
      hint: 'Double tap to ${isBookmarked ? "remove" : "save"} mentor',
      child: InkWell(
        onTap: () {
          context.read<MentorshipBloc>().add(
                ToggleBookmark(mentor.id, isCurrentlyBookmarked: isBookmarked),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isBookmarked ? 'Bookmark removed' : 'Mentor saved!',
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isBookmarked
                ? _teal.withValues(alpha: 0.25)
                : _teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 15,
                color: _teal,
              ),
              const SizedBox(width: 4),
              AccessibleText(
                isBookmarked ? 'Saved' : 'Save',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D4D4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}