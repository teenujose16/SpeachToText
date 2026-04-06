import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoiceAssistantScreen(),
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final Record _recorder = Record();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool isListening = false;
  String recognizedText = "Tap mic and speak...";
  Timer? silenceTimer;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (!available) return;

    setState(() => isListening = true);

    _speech.listen(
      onResult: (result) {
        setState(() => recognizedText = result.recognizedWords);

        // Restart silence timer
        silenceTimer?.cancel();
        silenceTimer = Timer(const Duration(seconds: 3), _stopListening);

        if (result.finalResult) {
          _stopListening();
        }
      },
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    silenceTimer?.cancel();
    await _speech.stop();

    setState(() => isListening = false);

    if (recognizedText.isNotEmpty) {
      await _speak("You said: $recognizedText");
    }
  }

  Future<void> _speak(String message) async {
    await _tts.speak(message);
  }

  @override
  void dispose() {
    silenceTimer?.cancel();
    _recorder.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech to Text Demo")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            recognizedText,
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isListening ? _stopListening : _startListening,
        child: Icon(isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}