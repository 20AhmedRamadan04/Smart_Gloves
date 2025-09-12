import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TranslationScreen extends StatefulWidget {
  final Stream<String> dataStream;
  final bool isTtsEnabled;
  final ValueChanged<bool> onTtsStateChanged;

  TranslationScreen({
    required this.dataStream,
    required this.isTtsEnabled,
    required this.onTtsStateChanged,
  });

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  late String _translatedText;
  late FlutterTts flutterTts;
  late StreamSubscription<String> _subscription;
  late bool _isTtsEnabled;

  @override
  void initState() {
    super.initState();
    _translatedText = ''; // Initialize with empty string
    _isTtsEnabled = widget.isTtsEnabled;
    flutterTts = FlutterTts();
    _initializeTts();
    _subscription = widget.dataStream.listen((data) {
      setState(() {
        _translatedText = data;
        if (_isTtsEnabled) {
          _speakArabic(_translatedText);
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakArabic(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  Future<void> _stopTts() async {
    await flutterTts.stop();
  }

  void _onSwitchChanged(bool value) {
    setState(() {
      _isTtsEnabled = value;
      widget.onTtsStateChanged(value);
      if (!value) {
        _stopTts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ترجمة النص', style: TextStyle(fontFamily: 'ArabicFont', fontSize: 24)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Move text slightly upwards
            Text(
              _translatedText,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'ArabicFont', fontSize: 28), // تكبير حجم النص
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('تشغيل الصوت', style: TextStyle(fontFamily: 'ArabicFont', fontSize: 20)),
                Switch(
                  value: _isTtsEnabled,
                  onChanged: _onSwitchChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
