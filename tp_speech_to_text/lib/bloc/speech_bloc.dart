import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'speech_event.dart';
import 'speech_state.dart';

class SpeechBloc extends Bloc<SpeechEvent, SpeechState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Timer? _silenceTimer;

  SpeechBloc() : super(const SpeechState()) {
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<SpeechResultReceived>(_onSpeechResultReceived);
    on<AmplitudeUpdated>(_onAmplitudeUpdated);
    on<TtsFinished>(_onTtsFinished);

    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      add(TtsFinished());
    });
  }

  Future<void> _onStartListening(StartListening event, Emitter<SpeechState> emit) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          add(StopListening()); 
        }
      },
      onError: (errorNotification) {
         // handle error gracefully
      }
    );
    
    if (!available) {
      emit(state.copyWith(error: "Speech recognition not available", isListening: false));
      return;
    }
    
    _resetSilenceTimer();

    emit(state.copyWith(
      isListening: true, 
      recognizedText: "Listening...", 
      error: '',
    ));

    await _speech.listen(
      onResult: (result) {
        add(SpeechResultReceived(result.recognizedWords, result.finalResult));
      },
      onSoundLevelChange: (level) {
        add(AmplitudeUpdated(level));
      },
      listenOptions: stt.SpeechListenOptions(listenMode: stt.ListenMode.confirmation),
    );
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 4), () {
      add(StopListening());
    });
  }

  Future<void> _onStopListening(StopListening event, Emitter<SpeechState> emit) async {
    _silenceTimer?.cancel();
    
    if (state.isListening == false) return;

    await _speech.stop();

    emit(state.copyWith(isListening: false, amplitude: -50.0));

    // If we have some spoken text
    if (state.recognizedText.isNotEmpty && 
        state.recognizedText != "Listening..." && 
        state.recognizedText != "Tap mic to start...") {
          
      List<String> newPhrases = List.from(state.lastPhrases);
      
      // Prevent adding multiple entries of the identical phrase back-to-back
      if (newPhrases.isEmpty || newPhrases.first != state.recognizedText) {
        newPhrases.insert(0, state.recognizedText);
        if (newPhrases.length > 5) {
          newPhrases = newPhrases.take(5).toList();
        }
        
        emit(state.copyWith(lastPhrases: newPhrases));
        await _tts.speak("You said: ${state.recognizedText}");
      }
    }
  }

  Future<void> _onSpeechResultReceived(SpeechResultReceived event, Emitter<SpeechState> emit) async {
    emit(state.copyWith(recognizedText: event.text));
    _resetSilenceTimer();
    
    if (event.isFinal) {
      add(StopListening());
    }
  }

  Future<void> _onAmplitudeUpdated(AmplitudeUpdated event, Emitter<SpeechState> emit) async {
    emit(state.copyWith(amplitude: event.amplitude));
  }

  Future<void> _onTtsFinished(TtsFinished event, Emitter<SpeechState> emit) async {
    // Restart listening loop automatically
    add(StartListening());
  }

  @override
  Future<void> close() {
    _silenceTimer?.cancel();
    _speech.cancel();
    _tts.stop();
    return super.close();
  }
}
