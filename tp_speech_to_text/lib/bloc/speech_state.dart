import 'package:equatable/equatable.dart';

class SpeechState extends Equatable {
  final bool isListening;
  final String recognizedText;
  final List<String> lastPhrases;
  final double amplitude;
  final String error;

  const SpeechState({
    this.isListening = false,
    this.recognizedText = "Tap mic to start...",
    this.lastPhrases = const [],
    this.amplitude = -50.0,
    this.error = '',
  });

  SpeechState copyWith({
    bool? isListening,
    String? recognizedText,
    List<String>? lastPhrases,
    double? amplitude,
    String? error,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      lastPhrases: lastPhrases ?? this.lastPhrases,
      amplitude: amplitude ?? this.amplitude,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isListening, recognizedText, lastPhrases, amplitude, error];
}
