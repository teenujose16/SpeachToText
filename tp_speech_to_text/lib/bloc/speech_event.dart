import 'package:equatable/equatable.dart';

abstract class SpeechEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartListening extends SpeechEvent {}

class StopListening extends SpeechEvent {}

class SpeechResultReceived extends SpeechEvent {
  final String text;
  final bool isFinal;

  SpeechResultReceived(this.text, this.isFinal);

  @override
  List<Object?> get props => [text, isFinal];
}

class AmplitudeUpdated extends SpeechEvent {
  final double amplitude;

  AmplitudeUpdated(this.amplitude);

  @override
  List<Object?> get props => [amplitude];
}

class TtsFinished extends SpeechEvent {}
