import 'package:translator/translator.dart';

class TranslationService {
  final _translator = GoogleTranslator();

  /// Translate text from source language to target language
  Future<String> translate({
    required String text,
    String from = 'en', // default source (English)
    required String to,  // target e.g. 'rw', 'fr'
  }) async {
    if (text.trim().isEmpty) return text;

    try {
      final translation = await _translator.translate(
        text,
        from: from,
        to: to,
      );
      return translation.text;
    } catch (e) {
      return text; // fallback to original text
    }
  }

  /// Batch translate multiple strings
  Future<List<String>> translateMultiple({
    required List<String> texts,
    String from = 'en',
    required String to,
  }) async {
    return Future.wait(
      texts.map((text) => translate(text: text, from: from, to: to)),
    );
  }
}