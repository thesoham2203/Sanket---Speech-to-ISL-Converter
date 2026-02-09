# Project Report 4

## Finalization of Requirements

The finalized scope for this iteration is constrained to features implemented in the repository:

- Real-time speech capture → optional translation to English → ISL rendering per token.
- Fallback finger-spelling for unknown tokens.
- Speed control, TTS playback.
- Persistent translation history (20 most recent, unique) and language preference.
- ISL learning quiz over a small fixed vocabulary.
  Out-of-scope: Authentication, notifications, backend sync, admin roles, and comprehensive vocabulary.

## Review and Prioritization

Priority P1 (MVP must-have):

- Speech capture, translation normalization, ISL mapping and display.
- Clear listening/translating visual feedback.
- History replay and language persistence.
  Priority P2 (Enhancements present):
- Quiz module, TTS, speed control.
  Priority P3 (Future):
- Phrase detection (commented scaffold), vocabulary expansion, backend/cloud features.

## Use Case Development

Primary use cases grounded in code:

1. Start Listening and Translate
2. Adjust Sign Speed
3. Replay Prior Translation from History
4. Play TTS for Current Translation
5. Take ISL Quiz

### Use Case 1: Start Listening and Translate

- Actor: User
- Precondition: Microphone permission granted; internet available for non-English translation.
- Main Flow:
  1. User taps mic → `_listen()` starts, sets `_isListening=true`.
  2. Speech recognition captures text (`recognizedWords`).
  3. If `_selectedLanguage != 'en'`, call translator; else use raw text.
  4. User taps mic again → stop; persist text; execute `translation()` to display signs sequentially.
- Postcondition: ISL sequence shown; history updated.
- Alternate/Exception: Translator failure → fall back to original text (try/catch path).

### Use Case 2: Adjust Sign Speed

- Actor: User
- Flow: Drag slider (0.5–2.0) → `_displaySpeed` updated; subsequent frame delays are divided accordingly.

### Use Case 3: Replay from History

- Actor: User
- Flow: Open History → tap replay → `Navigator.pop(text)` → `SpeechScreen` receives text → calls `translation(text)`.

### Use Case 4: Play TTS

- Actor: User
- Flow: Tap speaker icon when translation text present → `_tts.speak(_text)`.

### Use Case 5: ISL Quiz

- Actor: User
- Flow: Start quiz → app picks random `currentWord` from availableWords → show GIF → present four options → user selects → immediate feedback → next question until 10 → show final score dialog.

## Constraints and Assumptions

- Assumes assets present with exact filenames: `assets/ISL_Gifs/<word>.gif`, `assets/letters/<char>.png`, `assets/letters/space.png`.
- Durations are encoded as strings adjacent to word entries in `utils.words` and parsed to int.
- Translator availability is not guaranteed; network failures are handled gracefully but reduce normalization accuracy.
- `SharedPreferences` persistence is best-effort and synchronous at UI level (small datasets only).
- Locale mapping assumes `'<code>-IN'` variants for non-English languages during listening.

## Software Requirements Specification (SRS)

### 1. Introduction

- Purpose: Provide a mobile tool for speech-to-ISL visualization and learning.
- Scope: Single-user, device-local operation with cloud translation only.
- Definitions: ISL GIF — pre-rendered animation for word; Finger-spelling — per-character static image sequence.

### 2. Overall Description

- Product Perspective: Standalone mobile app; no backend dependencies beyond translator API.
- User Characteristics: General population; no sign language background required.
- Constraints: Asset availability; device microphone; internet for translation.

### 3. Specific Requirements

- FR-01: Start/stop speech recognition; display listening status.
- FR-02: Translate to English when `_selectedLanguage != 'en'`.
- FR-03: Tokenize and map each token to ISL GIF if present; else fallback to letters.
- FR-04: Insert space frame between tokens; show progress with animations.
- FR-05: Persist unique history entries up to 20 and expose retrieval/clear operations.
- FR-06: Provide quiz with 10 randomized questions from limited word set.
- NFR-01: Average UI frame rendering ≥ 60fps during idle; no blocking network calls on UI thread (awaited with minimal setState).
- NFR-02: Error handling for translator failures without app crash.
- NFR-03: App size bounded by asset pack; memory usage under typical device limits.

### 4. External Interface Requirements

- Microphone permission; internet access for translation.
- Assets declared in `pubspec.yaml` under `flutter.assets`.

### 5. System Features

- Speech capture, multi-language normalization, ISL display, history, quiz, and TTS as enumerated.

### 6. Other Requirements

- Accessibility: Visual emphasis, clear icons; TTS for auditory reinforcement.

## Stakeholder Review and Constraints

- Technical: Dependent on translator connectivity; asset pipeline must be consistent and versioned.
- Operational: Users expect common words to be available; letter fallback should be considered a secondary experience.
- Economic: Scaling vocabulary requires content creation investment.
- Environmental: Battery consumption should be limited (short sessions, serialized GIF playback) — current design aligns with this.
