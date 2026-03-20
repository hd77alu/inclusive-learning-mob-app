import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/mentorship_bloc.dart';
import '../../data/models/mentor_model.dart';
import '../screens/mentor_profile_edit_screen.dart';

class MentorCard extends StatelessWidget {
  final MentorModel mentor;
  final bool isBookmarked;
  final String userId;

  const MentorCard({
    super.key,
    required this.mentor,
    required this.isBookmarked,
    required this.userId,
  });

  static const _cyan = Color(0xFF1AFFFF);

  // ── Bookmark ────────────────────────────────────────────────────────────────
  void _onBookmark(BuildContext context) {
    context
        .read<MentorshipBloc>()
        .add(ToggleBookmark(userId, mentor.id, isBookmarked: isBookmarked));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_snackBar(
        isBookmarked ? 'Bookmark removed' : 'Mentor saved!',
      ));
  }

  // ── Action launchers ────────────────────────────────────────────────────────
  Future<void> _onMessage(BuildContext context) async {
    if (mentor.phone.isEmpty) {
      _showMissingSnackBar(context, 'No phone number available for this mentor');
      return;
    }
    final uri = Uri(scheme: 'sms', path: mentor.phone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        _showMissingSnackBar(context, 'Could not open messaging app');
      }
    }
  }

  Future<void> _onCall(BuildContext context) async {
    if (mentor.phone.isEmpty) {
      _showMissingSnackBar(context, 'No phone number available for this mentor');
      return;
    }
    final uri = Uri(scheme: 'tel', path: mentor.phone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        _showMissingSnackBar(context, 'Could not open phone dialer');
      }
    }
  }

  Future<void> _onVideo(BuildContext context) async {
    if (mentor.videoUrl.isEmpty) {
      _showMissingSnackBar(context, 'No video call link available for this mentor');
      return;
    }
    final uri = Uri.parse(mentor.videoUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        _showMissingSnackBar(context, 'Could not open video call link');
      }
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  SnackBar _snackBar(String message) {
    return SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.black)),
      backgroundColor: _cyan,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showMissingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E4A50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2426),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(context),
          _buildContent(),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 155,
          width: double.infinity,
          child: mentor.imageUrl.isNotEmpty
              ? Image.network(
                  mentor.imageUrl,
                  key: ValueKey(mentor.imageUrl),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 155,
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: _cyan, strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) => _imageFallback(),
                )
              : _imageFallback(),
        ),

        if (mentor.isOnline)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ONLINE NOW',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

        Positioned(
          top: 6,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconButton(
                icon: Icons.camera_alt_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MentorProfileEditScreen(mentor: mentor),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _iconButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                onTap: () => _onBookmark(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: _cyan, size: 22),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 155,
      color: Colors.black26,
      child: const Center(
        child: Icon(Icons.person, size: 56, color: Colors.white30),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mentor.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            mentor.specialty,
            style: const TextStyle(color: _cyan, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            mentor.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: mentor.tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _cyan),
                      ),
                      child: Text(tag,
                          style:
                              const TextStyle(color: _cyan, fontSize: 11)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF203033),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            context: context,
            icon: Icons.message_rounded,
            label: 'Message',
            onTap: () => _onMessage(context),
          ),
          _actionButton(
            context: context,
            icon: Icons.call_rounded,
            label: 'Call',
            onTap: () => _onCall(context),
          ),
          _actionButton(
            context: context,
            icon: Icons.videocam_rounded,
            label: 'Video',
            onTap: () => _onVideo(context),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(side: BorderSide(color: _cyan)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: _cyan, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
