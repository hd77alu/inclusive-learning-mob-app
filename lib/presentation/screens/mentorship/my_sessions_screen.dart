import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/blocs/session_bloc.dart';
import '/data/services/firestore_service.dart';
import '/data/models/session_model.dart';
import '/presentation/widgets/accessible_widgets.dart';
import '/presentation/widgets/accessibility_provider.dart';

class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _teal = Color(0xFF00D4D4);
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B1E) : const Color(0xFFF5F5F5);

    return BlocProvider(
      create: (_) => SessionBloc(FirestoreService())..add(LoadUpcomingSessions()),
      child: Builder(
        builder: (builderContext) => BlocListener<SessionBloc, SessionState>(
          listener: (context, state) {
            if (state is SessionCancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session cancelled successfully'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is SessionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: Column(
              children: [
                _buildHeader(context),
                _buildTabBar(isDark, builderContext),
                Expanded(child: _buildTabBarView()),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                  'My Sessions',
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

  Widget _buildTabBar(bool isDark, BuildContext blocContext) {
    final a11y = AccessibilityProvider.of(context);
    return Container(
      color: isDark ? const Color(0xFF1A2426) : Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          if (index == 0) {
            blocContext.read<SessionBloc>().add(LoadUpcomingSessions());
          } else {
            blocContext.read<SessionBloc>().add(LoadPastSessions());
          }
        },
        indicatorColor: _teal,
        labelColor: _teal,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * a11y.fontSizeMultiplier),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Past'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSessionsList(isUpcoming: true),
        _buildSessionsList(isUpcoming: false),
      ],
    );
  }

  Widget _buildSessionsList({required bool isUpcoming}) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state is SessionsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: _teal),
          );
        }

        if (state is SessionsLoaded) {
          if (state.sessions.isEmpty) {
            return _buildEmptyState(isUpcoming);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.sessions.length,
            itemBuilder: (context, index) {
              return _SessionCard(
                session: state.sessions[index],
                isUpcoming: isUpcoming,
              );
            },
          );
        }

        return _buildEmptyState(isUpcoming);
      },
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUpcoming ? Icons.calendar_today : Icons.history,
                size: 48,
                color: _teal,
              ),
            ),
            const SizedBox(height: 20),
            AccessibleText(
              isUpcoming ? 'No upcoming sessions' : 'No past sessions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            AccessibleText(
              isUpcoming
                  ? 'Book a session with a mentor to get started'
                  : 'Your completed sessions will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final bool isUpcoming;

  const _SessionCard({required this.session, required this.isUpcoming});

  static const Color _teal = Color(0xFF00D4D4);

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.confirmed:
        return Colors.green;
      case SessionStatus.cancelled:
        return Colors.red;
      case SessionStatus.completed:
        return Colors.blue;
      case SessionStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusLabel() {
    switch (session.status) {
      case SessionStatus.confirmed:
        return 'Confirmed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A2426) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: _teal, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccessibleText(
                        session.mentorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AccessibleText(
                          _getStatusLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: subtextColor),
                const SizedBox(width: 6),
                AccessibleText(
                  '${session.date.day}/${session.date.month}/${session.date.year}',
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: subtextColor),
                const SizedBox(width: 6),
                AccessibleText(
                  session.timeSlot,
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
              ],
            ),
            if (session.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D1B1E)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note_outlined, size: 16, color: subtextColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AccessibleText(
                        session.note,
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isUpcoming && session.status == SessionStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const AccessibleText('Cancel Session'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Session',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to cancel your session with ${session.mentorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SessionBloc>()
                  .add(CancelSession(session.id, session.mentorId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
