import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/mentorship_bloc.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/mentor_card.dart';

class MentorshipHubScreen extends StatelessWidget {
  const MentorshipHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pushReplacementNamed(context, '/signup'),
      );
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) =>
          MentorshipBloc(FirestoreService(), user.uid)..add(LoadMentors()),
      child: const _MentorshipHubView(),
    );
  }
}

class _MentorshipHubView extends StatefulWidget {
  const _MentorshipHubView();

  @override
  State<_MentorshipHubView> createState() => _MentorshipHubViewState();
}

class _MentorshipHubViewState extends State<_MentorshipHubView> {
  static const _bg = Color(0xFF0D1B1E);
  static const _cyan = Color(0xFF1AFFFF);
  static const _headerColor = Color(0xFF1AFFFF);
  static const _searchBg = Color(0xFF1A2426);
  static const _filters = ['All', 'Sign Language', 'Braille'];

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return BlocListener<MentorshipBloc, MentorshipState>(
      listenWhen: (prev, curr) =>
          curr is MentorshipLoaded &&
          prev is MentorshipLoaded &&
          prev.bookmarkedIds != curr.bookmarkedIds,
      listener: (context, state) {
        if (state is MentorshipLoaded) {
          // SnackBar is triggered from MentorCard via bookmark toggle
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _buildSearchBar(),
              ),
              BlocBuilder<MentorshipBloc, MentorshipState>(
                buildWhen: (prev, curr) => curr is MentorshipLoaded,
                builder: (context, state) {
                  final selected =
                      state is MentorshipLoaded ? state.selectedFilter : 'All';
                  return SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _filters.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) => _FilterChip(
                        label: _filters[i],
                        isSelected: selected == _filters[i],
                        onTap: () => context
                            .read<MentorshipBloc>()
                            .add(FilterMentors(_filters[i])),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<MentorshipBloc, MentorshipState>(
                  builder: (context, state) {
                    if (state is MentorshipLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: _cyan),
                      );
                    }

                    if (state is MentorshipError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                color: Color(0xFF8EADB3), size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Something went wrong.\n${state.message}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.redAccent.shade100,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context
                                  .read<MentorshipBloc>()
                                  .add(LoadMentors()),
                              child: const Text('Retry',
                                  style: TextStyle(color: _cyan)),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is MentorshipLoaded) {
                      final q = _searchQuery.toLowerCase();
                      final mentors = q.isEmpty
                          ? state.mentors
                          : state.mentors
                              .where((m) =>
                                  m.name.toLowerCase().contains(q) ||
                                  m.specialty.toLowerCase().contains(q) ||
                                  m.tags.any((t) =>
                                      t.toLowerCase().contains(q)))
                              .toList();

                      if (mentors.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  color: Color(0xFF8EADB3), size: 48),
                              SizedBox(height: 12),
                              Text(
                                'No mentors found.',
                                style: TextStyle(
                                    color: Color(0xFF8EADB3), fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        itemCount: mentors.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, i) => MentorCard(
                          mentor: mentors[i],
                          isBookmarked:
                              state.bookmarkedIds.contains(mentors[i].id),
                          userId: user.uid,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _headerColor,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 20),
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inclusive Learning Platform',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Mentorship Hub',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 1.5),
              color: Colors.black12,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.black, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search mentors by specialty...',
        hintStyle: const TextStyle(color: Color(0xFF6A8A90), fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6A8A90)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Color(0xFF6A8A90), size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: _searchBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: _cyan, width: 1.2),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const _cyan = Color(0xFF1AFFFF);
  static const _cardBg = Color(0xFF1A2426);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _cyan : _cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? _cyan : const Color(0xFF2E4A50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFF8EADB3),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
