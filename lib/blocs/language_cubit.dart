// lib/bloc/language/language_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../data/services/translation_service.dart';
class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('en'); // default English

  final TranslationService _translationService = TranslationService();

  // Load saved language from Firestore (similar to your Accessibility setup)
  Future<void> loadLanguage(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final lang = doc.data()?['preferredLanguage'] as String? ?? 'en';
      emit(lang);
    } catch (_) {}
  }

  // Change language + save to Firestore
  Future<void> changeLanguage(String newLang, String userId) async {
    emit(newLang);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'preferredLanguage': newLang}, SetOptions(merge: true));
  }

  // Helper to translate any text
  Future<String> translateText(String text, {String? from}) async {
    return await _translationService.translate(
      text: text,
      from: from ?? 'en',
      to: state,
    );
  }
}