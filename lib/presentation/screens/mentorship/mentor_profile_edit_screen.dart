import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '/data/models/mentor_model.dart';
import '/data/services/firestore_service.dart';
import '/presentation/widgets/accessible_widgets.dart';

class MentorProfileEditScreen extends StatefulWidget {
  final Mentor mentor;

  const MentorProfileEditScreen({super.key, required this.mentor});

  @override
  State<MentorProfileEditScreen> createState() =>
      _MentorProfileEditScreenState();
}

class _MentorProfileEditScreenState extends State<MentorProfileEditScreen> {
  static const _bg = Color(0xFF0D1B1E);
  static const _cyan = Color(0xFF1AFFFF);
  static const _cardBg = Color(0xFF1A2426);

  final _service = FirestoreService();
  bool _uploading = false;
  String? _previewUrl; // optimistic local preview

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('mentor_pictures')
          .child('${widget.mentor.id}.jpg');

      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      // Write new URL back to Firestore
      await _service.updateMentorImage(widget.mentor.id, url);

      if (mounted) {
        setState(() => _previewUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mentor picture updated!',
                style: TextStyle(color: Colors.black)),
            backgroundColor: _cyan,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _cyan),
              title: const AccessibleText('Take a photo',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_rounded, color: _cyan),
              title: const AccessibleText('Choose from gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUrl = _previewUrl ?? widget.mentor.imageUrl;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _cyan,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const AccessibleText('Edit Mentor Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Mentor image with edit overlay ───────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: displayUrl.isNotEmpty
                        ? Image.network(
                            displayUrl,
                            key: ValueKey(displayUrl),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: _cardBg,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: _cyan, strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) =>
                                _fallback(),
                          )
                        : _fallback(),
                  ),
                ),
                if (_uploading)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: _cyan, strokeWidth: 3),
                        ),
                      ),
                    ),
                  ),
                if (!_uploading)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: _showPickerSheet,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: _cyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 20, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Mentor info (read-only) ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibleText(
                    widget.mentor.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AccessibleText(
                    widget.mentor.role,
                    style: const TextStyle(color: _cyan, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  AccessibleText(
                    widget.mentor.description,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Change photo button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _uploading ? null : _showPickerSheet,
                icon: const Icon(Icons.upload_rounded, color: Colors.black),
                label: const AccessibleText('Change Mentor Photo',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cyan,
                  disabledBackgroundColor: _cyan.withAlpha(120),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: _cardBg,
      child: const Center(
        child: Icon(Icons.person, size: 64, color: Colors.white24),
      ),
    );
  }
}
