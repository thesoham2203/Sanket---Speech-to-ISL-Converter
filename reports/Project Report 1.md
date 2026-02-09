# Project Report 1

## Synopsis

Sanket is a Flutter-based mobile application that converts spoken input in seven supported Indian languages into Indian Sign Language (ISL) visual representations. Speech is recognized on-device (speech_to_text), optionally machine-translated to English (translator), mapped to ISL GIF assets (per known vocabulary) or finger‑spelled using static letter images when no direct sign exists, and displayed sequentially with adaptive timing and user-controlled playback speed. The app additionally provides an ISL learning quiz mode and persistent local translation history (SharedPreferences) for quick replay.

## Introduction

Communication barriers between hearing individuals and members of the Deaf and Hard of Hearing (DHH) community can inhibit inclusion. Sanket addresses this by offering a lightweight virtual interpreter focused on one-way speech → ISL translation and learning reinforcement. Implemented in Flutter, the application emphasizes portability (Android/iOS), fast local interaction, and a modular separation between input capture, language normalization, mapping logic, asset presentation, and user learning tools.

## Problem Statement

Real-time access to Indian Sign Language interpretation is limited by scarcity of trained interpreters and geographic, temporal constraints. Existing generic translation tools seldom integrate ISL assets or pedagogical aids. There is a need for a cost-effective, offline-friendly (for core features), locally installed mobile solution to: (1) convert everyday spoken phrases into ISL; (2) teach learners foundational ISL through repetition and assessment; (3) preserve recent translations for quick recall. Sanket aims to reduce latency, cognitive load, and entry barriers for basic ISL interaction.

## Objectives

- Capture and transcribe speech across multiple Indian languages with minimal user steps.
- Normalize non-English speech to English to align with currently available ISL vocabulary assets.
- Map recognized words or tokens to corresponding ISL GIF animations with accurate, configurable display durations.
- Fall back to character-level finger-spelling using letter image assets when a direct word sign is unavailable.
- Provide a quiz module to reinforce learning of core vocabulary.
- Persist the last 20 distinct translations locally for rapid replay.
- Maintain a responsive, visually clear UI with animation feedback for listening, loading, and sign progression.

## Project Scope

In-scope:

- One-way speech → ISL sign visualization.
- Seven source languages (en, hi, mr, ta, te, gu, bn) converted to English base set.
- Limited curated vocabulary (currently: words [hello, you, good, morning]; phrase list scaffolded but commented out).
- Quiz for four core words with randomized distractors.
- Local persistence (SharedPreferences) for history and language preference.
- Adjustable sign playback speed (0.5x–2.0x).
  Out-of-scope (current codebase):
- User authentication / accounts.
- Cloud synchronization or remote databases.
- Two-way (ISL video → text) recognition.
- Notification systems, background services.
- Comprehensive error analytics or logging framework.

## Methodology

Workflow pipeline:

1. Initialization: Splash screen → `SpeechScreen` sets up speech engine, translator, TTS, animation controllers, loads saved language.
2. Speech Capture: User taps mic (FloatingActionButton with AvatarGlow). `speech_to_text` starts listening with locale variant driven by dropdown language selection.
3. Transcription & Optional Translation: Interim recognized words captured; if language ≠ English, translator package translates full recognized phrase to English.
4. History Persistence: On stop (second tap), final text saved via `HistoryManager.saveTranslation` (Front-loaded uniqueness by removing duplicates before insert).
5. Mapping Logic: `translation()` processes lowercase string, splits by spaces. For each token:
   - Direct match in `utils.words` list yields GIF asset and duration (stored as adjacent string pair word,duration).
   - Fuzzy matches using synonyms lists (`hello`, `you`) map variants to canonical assets.
   - Otherwise token decomposed to characters; each character matched in `utils.letters` → letter PNG; unknown characters produce a space placeholder.
   - Between tokens, an intentional space frame (`space.png`) inserted to visually separate signs.
6. Rendering: AnimatedSwitcher keyed by `_state` updates image container; durations awaited asynchronously with speed factor division.
7. Learning Quiz: `QuizScreen` selects a random word from availableWords, displays corresponding GIF, constructs options (correct + others + fallback dummy words) then evaluates selection, updates score, advances until 10 questions.
8. History Replay: `HistoryScreen` fetches stored list; tapping replay pops with selected text back to `SpeechScreen` where translation pipeline re-runs.

## Modules

- UI Layer: `main.dart` (App root, splash), `speechToSign.dart` (primary interaction), `quiz_screen.dart` (learning), `history_screen.dart` (history listing).
- Data / Persistence: `history_manager.dart` (SharedPreferences wrappers).
- Domain Logic: `translation()` and `filterKnownStr()` in `speechToSign.dart`; vocabulary & mapping tables in `utils.dart`.
- Assets: `/assets/ISL_Gifs/*.gif` for word signs; `/assets/letters/*.png` for finger-spelling; `/assets/logo/*` for branding.

## Technologies Used

- Flutter (UI framework, cross-platform rendering).
- Dart (language for all app logic).
- Packages:
  - `speech_to_text`: Speech recognition session lifecycle and transcription.
  - `translator`: Cloud-based translation for non-English input normalization.
  - `flutter_tts`: Text-to-speech playback of translated content (English).
  - `shared_preferences`: Lightweight key-value persistence for history and language.
  - `avatar_glow`: Mic button glow animation state indicator.
  - `animated_splash_screen`, `page_transition`: Startup UX.
- Platform: Android (primary), iOS scaffold present.

## Conclusion

Sanket delivers a focused MVP for speech-to-ISL translation and foundational learning using a compact, asset-driven architecture. The modular separation between capture, normalization, mapping, and presentation enhances maintainability, while local history and speed control improve usability. Although current vocabulary coverage is limited and advanced features (two-way translation, accounts, sync) are absent, the codebase establishes a clear extension path: expanding `utils.dart` with more signs, uncommenting phrase lists, enhancing mapping heuristics, and integrating persistence layers. Sanket effectively demonstrates feasibility of real-time, mobile ISL visualization using commodity speech and translation services coupled with curated sign assets.
