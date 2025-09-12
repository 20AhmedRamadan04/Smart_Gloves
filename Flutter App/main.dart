import 'dart:async';
import 'translation_screen.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(fontFamily: 'ArabicFont', fontSize: 20), // Increase text size and unify font
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _translatedText = '';
  late bool _isTranslating = false;
  late bool _isTtsEnabled = false;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initializeTts();
    _fetchAndSetDataFromAPI();
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      print("TTS: Playing");
    });

    flutterTts.setCompletionHandler(() {
      print("TTS: Complete");
    });

    flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
    });

    print("TTS Initialized");
  }

  Stream<String> _dataStream = Stream.empty();

  Future<void> _fetchAndSetDataFromAPI() async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final initialData = await _fetchDataFromAPI();
      setState(() {
        _translatedText = initialData;
      });

      _dataStream = Stream.periodic(Duration(milliseconds: 150), (_) async { // Change duration to 500 milliseconds
        return await _fetchDataFromAPI();
      }).asyncMap((event) => event);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranslationScreen(
            dataStream: _dataStream,
            isTtsEnabled: _isTtsEnabled,
            onTtsStateChanged: (isEnabled) {
              setState(() {
                _isTtsEnabled = isEnabled;
              });
            },
          ),
        ),
      );
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<String> _fetchDataFromAPI() async {
    try {
      final response = await http.get(Uri.parse('Your_API_Url'));
      if (response.statusCode == 200) {
        var decodedResponse = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = jsonDecode(decodedResponse);
        String apiData = data['word'] ?? 'No data';

        return apiData;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to connect to API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مترجم لغة الإشارة', style: TextStyle(fontFamily: 'ArabicFont', fontSize: 24)),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isTranslating ? null : _fetchAndSetDataFromAPI,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Increase button size
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Give button a distinct shape
            ),
            textStyle: TextStyle(fontFamily: 'ArabicFont', fontSize: 24), // Increase text size
          ),
          child: Text('أبدأ'),
        ),
      ),
    );
  }
}
