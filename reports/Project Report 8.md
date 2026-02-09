# Project Report 8

## Supporting Documentation and Design Considerations

### UI/UX Design Choices

- Single-screen primary workflow minimizes navigation friction; critical actions (mic, speed, history, quiz) are accessible from app bar/FAB.
- Clear state indicators: glowing mic and "Listening..." pill, semi-transparent overlay with spinner during translation.
- Animated transitions (AnimatedSwitcher, ScaleTransition) support perceived smoothness without heavy computation.

### Architecture Considerations

- Asset-driven mapping avoids runtime ML inference costs and model maintenance; deterministic runtime behavior.
- Mapping logic centralized in `translation()` and `utils.dart` simplifies maintenance and auditing.
- Preference for explicit durations per GIF ensures predictable pacing across devices.

### Error Handling and Resilience

- Speech init guarded by availability boolean; errors printed to console in callbacks.
- Translation wrapped in try/catch; on exception, original text is used to keep the flow uninterrupted.
- Image errorBuilder displays a placeholder icon if an asset is missing or misnamed.

### Accessibility

- Large, high-contrast controls; textual labels and icons.
- TTS provides audio reinforcement.
- Speed control supports different learning needs.

### Internationalization

- Source language selection supports en/hi/mr/ta/te/gu/bn. Normalization to English aligns with available ISL assets.
- TTS fixed to `en-IN` for consistent pronunciation; could be made configurable later.

### Asset Naming and Duration Conventions

- Word GIFs: lowercase `<word>.gif` in `assets/ISL_Gifs/`.
- Letters: lowercase `a..z` and digits `0..9` in `assets/letters/` PNGs; `space.png` used as frame separator and unknown fallback.
- `utils.words` stores `[word, durationMsString]` for timing; parse with `int.parse()`.

### Testing Plans

- Manual Scenarios:
  - Mic permission prompts; start/stop listening; switch languages; offline mode behavior for translation.
  - Vocabulary mapping hits/misses; fallback letter rendering for unknown words; speed extremes (0.5x and 2.0x).
  - History cap behavior (insert 21st item removes oldest); replay.
  - Quiz flow correctness and score thresholds; final dialog actions.
- Automated (suggested additions):
  - Unit tests for `HistoryManager` operations (uniqueness, cap).
  - Unit tests for `translation()` tokenization and mapping decisions with stubbed durations.
  - Golden tests for key widgets (mic button states, history empty vs populated).

### Security and Privacy

- Microphone access used only during active listening session; no background recording.
- No cloud persistence; history remains on device. Translation text may transit to 3rd-party service during normalization for non-English inputs.

### Performance Tips for Future

- Convert `utils.words` to a map for O(1) lookup and store int durations directly.
- Preload small set of GIFs used in quiz for smoother transitions.
- Debounce setState updates in translation loop by batching frames or using an animation timeline.

### Build and Delivery Notes

- Assets are declared in `pubspec.yaml`; ensure new assets follow naming conventions and run `flutter pub get` after updates.
- App icon configuration present via `flutter_launcher_icons` section; run the generator after changing icon assets.
