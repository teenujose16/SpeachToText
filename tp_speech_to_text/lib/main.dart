import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/speech_bloc.dart';
import 'bloc/speech_event.dart';
import 'bloc/speech_state.dart';

void main() {
  runApp(const MyApp());
}

// --- App ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech To Text BLoC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: BlocProvider(
        create: (context) => SpeechBloc(),
        child: const VoiceAssistantScreen(),
      ),
    );
  }
}

// --- Main UI ---
class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Voice Assistant"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display current recognized text
              Expanded(
                flex: 3,
                child: Center(
                  child: BlocBuilder<SpeechBloc, SpeechState>(
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          state.recognizedText,
                          key: ValueKey<String>(state.recognizedText),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: state.isListening ? Colors.tealAccent : Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Animated Waveform/Amplitude Bar
              const SizedBox(height: 20),
              BlocBuilder<SpeechBloc, SpeechState>(
                buildWhen: (previous, current) => previous.amplitude != current.amplitude || previous.isListening != current.isListening,
                builder: (context, state) {
                  // speech_to_text amplitude typically falls between -50.0 and 50.0
                  double normalizedAmp = 0.0;
                  if (state.isListening) {
                     normalizedAmp = (state.amplitude + 50) / 100;
                     normalizedAmp = normalizedAmp.clamp(0.0, 1.0);
                  }
                  
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: normalizedAmp,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.tealAccent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.tealAccent.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Log of 5 recent phrases
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Phrases",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BlocBuilder<SpeechBloc, SpeechState>(
                        builder: (context, state) {
                          if (state.lastPhrases.isEmpty) {
                            return const Center(
                              child: Text(
                                "No history yet.",
                                style: TextStyle(color: Colors.white24),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: state.lastPhrases.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  state.lastPhrases[index],
                                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Mic Button
              Center(
                child: BlocBuilder<SpeechBloc, SpeechState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        if (state.isListening) {
                          context.read<SpeechBloc>().add(StopListening());
                        } else {
                          context.read<SpeechBloc>().add(StartListening());
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: state.isListening ? Colors.redAccent : Colors.teal,
                          shape: BoxShape.circle,
                          boxShadow: state.isListening 
                           ? [
                              BoxShadow(color: Colors.redAccent.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 4),
                             ]
                           : [],
                        ),
                        child: Icon(
                          state.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}