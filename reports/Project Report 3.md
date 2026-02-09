# Project Report 3

## Requirement Gathering

Approach leveraged direct analysis of existing code artifacts rather than stakeholder interviews. Source files (`speechToSign.dart`, `quiz_screen.dart`, `history_manager.dart`, `history_screen.dart`, `utils.dart`, `pubspec.yaml`) reveal implicit functional and non-functional requirements. Commented blocks (e.g., phrase list in `utils.dart`) signal planned expansion.

Methods utilized:

- Codebase inspection for implemented capabilities.
- Asset directory review for available vocabulary.
- Identification of configuration constants and constraints (max history size, durations, language codes).

## Functional Requirements (Implemented)

1. Speech Capture: Application shall start and stop audio transcription for a selected source language.
2. Multi-Language Support: Application shall translate recognized non-English speech to English prior to ISL mapping (languages: en, hi, mr, ta, te, gu, bn).
3. Translation History: Application shall store up to 20 distinct recent translations, excluding duplicates (move existing to front upon replay).
4. Replay: User shall request a past translation, triggering regeneration of ISL sign sequence.
5. ISL Mapping: Application shall render word-level sign GIFs for known vocabulary tokens and fallback to per-character finger spelling for unknown tokens.
6. Synonym Normalization: Application shall map variants (e.g., hello/hey/hi/hii/hay → "hello" sign; you/your/your's → "you" sign).
7. Sign Playback Timing: Application shall respect predefined durations (ms) per GIF, modulated by user-adjustable speed factor (0.5x–2.0x).
8. Quiz Module: Application shall present 10 randomized GIF questions from availableWords with four multiple-choice options, scoring correct answers and providing final performance feedback.
9. Text-to-Speech: Application shall synthesize audio output of translated English phrase via TTS.
10. UI Feedback: Application shall visually indicate listening state (glow + badge) and translation progress (overlay spinner).
11. Language Preference Persistence: Application shall persist last selected source language across sessions.
12. Pull-to-Refresh: User shall reset translation context by swipe gesture.

## Non-functional Requirements (Inferred)

- Performance: Display transitions should remain smooth (lightweight state updates, minimal layout thrashing). GIF sequence rendering is serialized to avoid overlapping heavy decoding.
- Responsiveness: Listening toggle and progress indicators must update within <100ms of state change.
- Usability: Single primary interaction path (mic button) with discoverable controls; speed control slider clearly annotated.
- Portability: Code targets Flutter stable; dependencies support Android/iOS (iOS scaffolding present but untested in code sample).
- Maintainability: Vocabulary stored centrally (`utils.dart`); adding words requires single point edits and asset placement.
- Reliability: Failure in translation gracefully falls back to original recognized text (try/catch). Speech initialization returns boolean availability.
- Data Persistence Integrity: History list operations prevent duplicate proliferation and maintain capped length.

## Features (Implemented vs Requested in Prompt)

Implemented subset only:

- Speech recognition
- Multi-language auto-translation to English
- ISL visualization (word GIF + letter fallback)
- Speed adjustment
- Local history + replay
- Quiz learning mode
- TTS playback
  Not implemented in current codebase (prompt mentions for completeness but absent):
- User management (registration/login)
- Real-time remote data integration
- Push/local notifications
- Admin functions or role separation
- Cloud synchronization
- Offline full vocabulary (only assets present locally)

## Methods Used for Requirement Collection

- Direct source analysis (structural and behavioral): Identifying state variables (`_isListening`, `_isTranslating`, `_selectedLanguage`, `_displaySpeed`).
- Asset naming conventions: Deriving mapping necessity (word.gif, letter.png).
- Code comments and commented-out arrays: Inferring roadmap (phrases list prepared for expansion, currently disabled).
- Package list in `pubspec.yaml`: Determining scope of dependencies and absent modules (no Firebase, signaling absence of remote backend).

## Traceability Matrix (Abbreviated)

| Requirement          | Source Artifact               | Implementation Element                          |
| -------------------- | ----------------------------- | ----------------------------------------------- |
| Speech Capture       | `speechToSign.dart`           | `_listen()` with `_speech.listen()`             |
| Multi-Language       | `speechToSign.dart`           | `_selectedLanguage` dropdown + translator usage |
| History Persistence  | `history_manager.dart`        | `saveTranslation()`, `getHistory()`             |
| Replay               | `history_screen.dart`         | `Navigator.pop(context, history[index])`        |
| Word Mapping         | `utils.dart` words list       | `translation()` direct match branch             |
| Synonym Handling     | `utils.dart` hello/you arrays | Variant mapping clauses                         |
| Finger Spelling      | `utils.dart` letters          | Character iteration loop in `translation()`     |
| Speed Control        | `speechToSign.dart` slider    | Duration division by `_displaySpeed`            |
| Quiz                 | `quiz_screen.dart`            | `generateQuestion()`, scoring logic             |
| TTS                  | `speechToSign.dart`           | `_tts.speak(_text)`                             |
| Language Persistence | `history_manager.dart`        | `saveLanguage()`, `getLanguage()`               |
| Refresh              | `speechToSign.dart`           | `_resetTranslation()` via `RefreshIndicator`    |

## Gap Analysis

Areas requested in original multi-report outline but absent in code:

- Authentication & Roles: No data model or package references.
- Notifications: No FCM/Local Notifications dependencies.
- Real-time data: No sockets/Web APIs integrated beyond translation API.
  Recommendation: Clearly denote in subsequent reports (Use Cases, SRS) that such features are out-of-scope for current iteration and classify as future enhancements.

## Conclusion

Requirements derivation from the extant code confirms a focused MVP around speech recognition, translation normalization, sign rendering, education via quiz, and simple persistence. Declaring explicit non-implemented features prevents scope creep and aligns future documentation (SRS, modeling) with reality while earmarking growth paths for vocabulary expansion, backend integration, and richer user personalization.
