# MindSync Project Report

## 1. Problem Statement
College students and young professionals often need fast, low-friction mental wellness support they can use daily. Existing apps can feel overwhelming, expensive, or too generic.

## 2. Proposed Solution
MindSync provides a lightweight daily companion that combines mood check-ins, reflection, guided calming activities, goals, reminders, and progress visibility in one app.

## 2.1 Feature Justification
- Mood tracking: creates a daily awareness habit and trend baseline.
- Journaling + CBT reframing: turns emotions into structured reflection.
- Guided meditation + breathing: immediate intervention for stress episodes.
- Goals + reminders: supports behavior consistency through small actions.
- Therapy/support locator map: helps users discover nearby real-world support.
- Dashboard analytics: provides motivation through progress visibility.

## 3. Architecture Overview
- `screens`: presentation/UI layer
- `widgets`: reusable visual components
- `providers`: state + app/domain orchestration
- `services`: integration layer (Firebase, Gemini, notifications)
- `models/data`: typed entities and local content

This separation keeps UI components focused on rendering and interaction while provider/service layers handle business logic and persistence.

### Architecture Diagram (Simplified)

```text
UI (screens/widgets)
   -> Provider (auth_provider, mood_provider)
      -> Services (firebase auth, firestore, gemini, notifications, overpass map API)
         -> External systems (Firebase, Gemini, OpenStreetMap/Overpass, device location)
```

## 4. Key Features Delivered
- Authentication and session-aware routing
- Mood logging with trend stats
- Journaling with AI-generated prompts and fallback prompt
- CBT thought reframing flow
- Guided meditation and breathing activities
- Goals CRUD and daily reminders
- Milestone unlocks and profile dashboard insights
- Mental health resources listing

## 5. AI Usage Disclosure
Gemini is used for assistive text generation (journal prompts, thought reframing, and encouragement content). Fallback behavior is included when AI output is unavailable.

### Manual Modifications by Team
- Prompt design tuned for short, practical outputs.
- Added fallback text paths when Gemini is unavailable.
- Integrated AI outputs into custom journaling/CBT user flow.
- Added custom error and empty-state UX around API-dependent features.

## 6. Challenges and Mitigations
- Network-dependent features: handled with fallback messages and graceful degradation.
- Firebase async state synchronization: solved using Provider refresh patterns.
- Scope control: delivered minimal high-impact UX and analytics required by DoD.

## 7. Outcome
MindSync meets the required end-to-end flow for a mental wellness assistant MVP with documented architecture, testing baseline, and deployment path.
