# History

## 2026-05-31 14:30 UTC — Grammar, reading, news overhaul + hover translation
- Grammar: expanded to 31 notes (up from 11) with real-life conversation examples
- Reading: 8 real-life passages (cafe, directions, doctor visit, social media, weekend plans)
- News: 8 curated stories covering culture, sports, weather, tech, science
- Hover-to-translate: hover any Russian word in Reading/News to see translation + jump to Vocabulary
- RussianFlowText: shared component for interactive Russian text rendering
- AppNavigation: cross-section navigation (hover popover → jump to Vocab)

## 2026-05-31 13:10 UTC — OpenRussian dictionary integration
- Integrated OpenRussian.org dataset (26,983 nouns, 9,964 verbs, 5,521 adjectives)
- 95 words now have full 12-case declension tables
- 28 verbs now have full conjugation tables (present + past tense)
- Conjugation display in Vocabulary detail panel
- CSV resource files for future dictionary search

## 2026-05-31 05:00 UTC — Major expansion
- **Vocabulary**: Expanded from 63 to 220+ words (greetings, food, verbs, motion, body, weather, colors, numbers, technology, emotions, prepositions)
- **Phrases**: Added 20 common phrases with context labels via PhraseEntry entity
- **Grammar**: Expanded from 5 to 11 notes with real-world examples and teaching tips (cases, motion verbs, counting, reflexives, же particle)
- **Deepseek API**: Implemented real AI chat with system prompt, chat history, suggestion chips, graceful error handling
- **Study calendar**: Heat map calendar on macOS Dashboard (12-week view + streak tracking)
- **Russian news**: News reading section with 4 curated stories, key vocab extraction, translations
- **Feedback system**: FeedbackEvent entity + FeedbackLogger for in-app usage logging

## 2026-05-31 03:55 UTC — Initial scaffold
- Multiplatform SwiftUI app (iOS + macOS) with Core Data + CloudKit sync
- iOS: Daily practice with SM-2 spaced repetition, Russian TTS
- macOS: Dashboard, grammar reference, reading, culture, AI Chat placeholder
- Seed content: 63 words + 5 grammar notes
