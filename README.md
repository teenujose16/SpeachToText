# SpeachToText
The Speech-to-Text Converter is an application that transforms spoken language into written text using audio processing and machine learning techniques. The system captures voice input through a microphone or audio file and converts it into accurate, readable text in real time or after processing.

**Productivity Observation:** 
Transitioning the speech engine to a decoupled BLoC architecture cleanly isolated the highly concurrent audio tracking states from the UI rendering layer. This immediately eliminated fatal native microphone lock conflicts and drastically simplified long-term feature expandability.
