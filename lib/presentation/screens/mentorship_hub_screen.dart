import 'package:flutter/material.dart';
import 'mentor_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/mentorship_bloc.dart';
import '../../services/firestore_service.dart';
import '../../models/mentor_model.dart';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter mentors by search text and selected chip
  List<Mentor> _filtered(List<Mentor> mentors) {
    final query = _searchController.text.toLowerCase();
    return mentors.where((m) {
      final matchesSearch = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.role.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' ||
          m.tags.any((t) =>
              t.toLowerCase().contains(_selectedFilter.toLowerCase()));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorshipBloc(FirestoreService())..add(LoadMentors()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            // ── Teal header ──
            _buildHeader(context),

            // ── Search bar ──
            _buildSearchBar(),

            // ── Filter chips ──
            _buildFilterChips(),

            // ── Mentor list ──
            Expanded(child: _buildMentorList()),
          ],
        ),
      ),
    );
  }

  // Top teal header with back arrow, title, profile icon
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Expanded(
            child: Text(
              'Mentorship Hub',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
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

  // Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search mentors by specialty...',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
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

  // Filter chips: All, Sign Language, Braille
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _filters[i] == _selectedFilter;
          return ChoiceChip(
            label: Text(_filters[i]),
            selected: selected,
            onSelected: (_) => setState(() => _selectedFilter = _filters[i]),
            selectedColor: _teal,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.black : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected ? _teal : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }

  // BLoC-driven mentor list
  Widget _buildMentorList() {
    return BlocConsumer<MentorshipBloc, MentorshipState>(
      listener: (context, state) {
        if (state is MentorshipError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load mentors')),
          );
        }
      },
      builder: (context, state) {
        if (state is MentorshipLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MentorshipLoaded) {
          final mentors = _filtered(state.mentors);

          if (mentors.isEmpty) {
            return const Center(child: Text('No mentors found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            itemCount: mentors.length,
            itemBuilder: (context, index) =>
                _MentorCard(mentor: mentors[index]),
          );
        }

        return const SizedBox();
      },
    );
  }
}

// ── Mentor Card Widget ──
class _MentorCard extends StatelessWidget {
  final Mentor mentor;
  const _MentorCard({required this.mentor});

  static const Color _teal = Color(0xFF00D4D4);

  @override
  Widget build(BuildContext context) {
    return Card(
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
            // Profile image area with ONLINE badge
            Stack(
              children: [
                // Avatar banner
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
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                ),

                // ONLINE NOW badge
                if (mentor.isOnline)
                  Positioned(
                    top: 10,
                    right: 12,
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
              ],
            ),

            // Card body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mentor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '⭐ ${mentor.rating}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Role/title
                  Text(
                    mentor.role,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  // Description
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

                  // Tags
                  if (mentor.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: mentor.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor:
                                  _teal.withValues(alpha: 0.12),
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

                  // Action buttons: Bookmark, Call, Video
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionButton(
                        icon: Icons.bookmark_border,
                        label: 'Save',
                        onTap: () {},
                      ),
                      _actionButton(
                        icon: Icons.call,
                        label: 'Call',
                        onTap: () {},
                      ),
                      _actionButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        onTap: () {},
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _teal),
            const SizedBox(width: 4),
            Text(
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
    );
  }
}