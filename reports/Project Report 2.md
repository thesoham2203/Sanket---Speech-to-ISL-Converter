# Project Report 2

## Feasibility Analysis

### Technical Feasibility

Current implementation relies exclusively on mature Flutter packages and local static assets; no proprietary or complex native integrations are required beyond microphone access. Core subsystems:

- Speech Recognition (`speech_to_text`): Abstracts platform nuances (Android/iOS). Initialization and error callbacks already handled. Low integration risk; widely adopted.
- Translation (`translator`): Simple REST-backed API (Google Translate) hidden behind package interface. Only used after speech capture; tolerant of transient network failure by falling back to original text.
- Asset-based Sign Rendering: Deterministic retrieval of GIF/PNG files; complexity bounded by asset count. Adding vocabulary requires extending `utils.words` (word,duration pair) and placing a GIF asset; no schema migrations.
- Persistence (`shared_preferences`): Key-value store sufficient for small history array (max 20 entries) and language preference. No contention or concurrency complexities (single-user local app).
- Performance / Memory: GIF durations are short; sequential asynchronous display prevents heavy concurrent asset decoding. Letter fallback PNG images are lightweight. State is simple booleans and small strings.
- Extensibility: Vocabulary expansion—append adjacent duration values. Phrase handling scaffolding exists (commented lists, `filterKnownStr()`), enabling future domain logic updates without structural overhaul.

Constraints:

- No offline translation for non-English languages (depends on network for translation); only raw transcription available offline.
- ISL asset coverage minimal: requires manual asset production for scaling.
- No formal state management library (e.g., Provider, Bloc); scaling complexity could rise if logic grows.

Overall: High technical feasibility with low complexity and clear extension pathways.

### Economic Feasibility

Direct operating costs are minimal:

- Translation API via `translator` package (piggybacks free Google Translate endpoints) — acceptable for prototype/MVP; may require paid tier or caching strategy at scale.
- Asset creation (ISL GIFs) is the most resource-intensive component (labor for recording, editing). Current small vocabulary reduces initial costs.
- No backend hosting, database, or authentication infrastructure — lowers maintenance expenditures.
  Future scaling cost drivers:
- Larger asset library production (time/equipment, possible licensing of standardized ISL resources).
- Potential transition to managed translation or speech services for reliability (paid API usage).
  Economic viability for limited educational scope and demonstration use is strong; costs remain predictable and primarily front-loaded into content creation.

### Operational Feasibility

User operation is straightforward:

- Single primary screen consolidating capture, language selection, speed control, history, and quiz entry.
- History replay reduces repeated speech for common phrases.
- Quiz fosters retention, increasing perceived value.
  Operational Risks:
- Limited vocabulary may frustrate users expecting broader coverage; fallback finger-spelling partially mitigates but may reduce satisfaction for expressive sentences.
- Dependence on network for multilingual translation can degrade experience in poor connectivity environments.
  Mitigations:
- Clear UI feedback states (listening, translating spinner) reduce uncertainty.
- Speed control offers personalization for viewing comfort.

## Viability Using Chosen Technologies

### Flutter

Pros: Rapid cross-platform development, rich widget ecosystem, hot-reload productivity. Current code already uses stock Material components with custom animation touches. Scaling UI complexity (adding learning modules, asset browsing) remains feasible without rewrite.

### Packages

- `speech_to_text`: Sufficient for continuous incremental transcription. Reusable for multi-language capture with locale selection.
- `translator`: Easily swappable if service limits encountered; interface use is narrow (single call per phrase).
- `shared_preferences`: Appropriate for small localized datasets. If user profiles or cloud sync are added, a migration to a remote store (Firebase Firestore, Supabase) would be needed.
- `flutter_tts`: Adds auditory reinforcement with minimal overhead.

### Potential Firebase / API Integration (Not Present Now)

While Firebase is not in the current codebase, potential future integrations:

- Firestore for centralized vocabulary updates and quiz question expansion without app redeployments.
- Remote config for dynamic enabling of phrase lists.
- Auth for personalized history across devices.
  Given existing architecture, introducing repository/service layers would isolate such integrations cleanly.

### Risks & Mitigations

| Risk                                  | Impact                       | Mitigation                                                                                      |
| ------------------------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------- |
| Translator API rate limiting          | Translation failures         | Graceful fallback (already: use original text if exception) + local caching of frequent phrases |
| Asset growth increases app size       | Slower installs, storage use | Progressive asset packs, optional downloads, lazy loading                                       |
| Lacking formal state management       | Harder feature scaling       | Introduce Provider/Riverpod for separation of concerns                                          |
| Speech recognition variance (accents) | Lower accuracy               | Add on-screen manual correction/edit box (future)                                               |

### Sustainability

The current clean separation of concerns (capture → transform → map → render) promotes maintainable growth. Minimal dependency footprint and absence of backend obligations enhance long-term sustainability for small teams or community contributors.

## Conclusion

Technically, economically, and operationally, Sanket is a viable MVP grounded in efficient use of Flutter ecosystems and lightweight local assets. The architecture readily supports incremental vocabulary expansion and educational feature enrichment. Strategic future adoption of backend services (Firebase or similar) can elevate synchronization and personalization without invalidating existing modules. Immediate viability for educational and assistive contexts is strong; scalability hinges mainly on curated sign asset production and improved mapping breadth.
