# Project Report 6

## Diagrams for Major Workflows

### 1) Sequence: Listen → Translate → Render

```mermaid
sequenceDiagram
  autonumber
  participant U as User
  participant UI as SpeechScreen
  participant STT as speech_to_text
  participant TR as translator
  participant PREF as SharedPreferences
  participant R as ISL Renderer

  U->>UI: Tap mic (start)
  UI->>STT: initialize(); listen(localeId)
  STT-->>UI: recognizedWords (interim/final)
  U->>UI: Tap mic (stop)
  UI->>STT: stop()
  UI->>PREF: saveTranslation(text)
  alt selectedLanguage != 'en'
    UI->>TR: translate(text, from=lang, to='en')
    TR-->>UI: translatedText
  else
    UI-->>UI: use text as translatedText
  end
  UI->>R: translation(translatedText)
  loop tokens
    R-->>UI: update frame (GIF if known; else letters)
  end
```

### 2) Sequence: History Replay

```mermaid
sequenceDiagram
  participant U as User
  participant HS as HistoryScreen
  participant UI as SpeechScreen
  participant PREF as SharedPreferences

  U->>UI: Tap history icon
  UI->>HS: push()
  HS->>PREF: getHistory()
  PREF-->>HS: [text1, text2, ...]
  U->>HS: Tap replay on item
  HS-->>UI: pop(text)
  UI-->>UI: translation(text)
```

### 3) Sequence: Quiz Answer Flow

```mermaid
sequenceDiagram
  participant U as User
  participant Q as QuizScreen

  U->>Q: Start Quiz
  Q-->>Q: generateQuestion() (random word, options)
  Q-->>U: Show GIF + 4 options
  U->>Q: Select option
  alt correct
    Q-->>Q: score++
  else
    Q-->>Q: score unchanged
  end
  Q-->>Q: next or final dialog after 10
```

## Activity Diagrams

### A) Activity: Translation Pipeline

```mermaid
flowchart TD
  A[Start] --> B{Listening?}
  B -- No --> C[Tap mic to start]
  B -- Yes --> D[Capture recognizedWords]
  D --> E[Tap mic to stop]
  E --> F[Persist text in history]
  F --> G{Language == en?}
  G -- Yes --> H[Use recognized text]
  G -- No --> I[Translate to English]
  H --> J[Split into tokens]
  I --> J
  J --> K{Known word in utils.words?}
  K -- Yes --> L[Render word.gif for duration]
  K -- No --> M[Iterate characters]
  M --> N{Letter in utils.letters?}
  N -- Yes --> O[Render letter.png]
  N -- No --> P[Render space.png]
  L --> Q[Insert space frame]
  O --> Q
  P --> Q
  Q --> R{More tokens?}
  R -- Yes --> K
  R -- No --> S[Done]
```

### B) Activity: Quiz Round

```mermaid
flowchart TD
  A[Start Quiz] --> B[Pick random currentWord]
  B --> C[Create options set]
  C --> D[Display GIF + options]
  D --> E{User selects}
  E -- Correct --> F[Increment score]
  E -- Wrong --> G[No change]
  F --> H{More questions?}
  G --> H
  H -- Yes --> B
  H -- No --> I[Show final score dialog]
```

## Notes on Non-Applicable Flows

- Login and Notifications are not part of the current codebase; no sequence or activity diagrams are included for them to avoid misrepresenting functionality.
