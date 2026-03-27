import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onResult;
  final Color? color;

  const VoiceSearchButton({
    super.key,
    required this.onResult,
    this.color,
  });

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onError: (error) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice search not available')),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
      ),
      onResult: (result) {
        if (result.finalResult) {
          widget.onResult(result.recognizedWords);
          setState(() => _isListening = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _isListening ? 'Stop voice search' : 'Start voice search',
      hint: _isListening ? 'Double tap to stop listening' : 'Double tap to speak your search',
      child: IconButton(
        icon: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: widget.color ?? Colors.grey,
        ),
        onPressed: _toggleListening,
        tooltip: _isListening ? 'Stop listening' : 'Voice search',
      ),
    );
  }
}
