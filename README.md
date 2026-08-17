# Sentinel AI

## Overview
Sentinel AI is an AI-powered community safety intelligence, risk analytics, and intelligent route decision support mobile application. It helps users analyze verified safety incidents, understand location risks, and make intelligent routing decisions using real-time data.

## Project Status
- **Phase 5P** — Responsive UI implementation and validation — COMPLETE
- **Phase 5Q** — Navigation, interaction and UX audit — COMPLETE

## Core Features
- **Safety Map:** Visualize incidents and location risks via an interactive map with draggable detail sheets.
- **Incident Reporting:** 5-step intuitive reporting flow with AI Classification previews.
- **Safety Assistant:** Conversational AI interface for contextual safety queries.
- **Trust & Safety:** Trip Safety Mode, Trusted Contacts, and real-time Alerts.
- **Emergency Access:** Persistent, accessible emergency support features across all major views.

## UI/UX
- **Sentinel Design System:** Strict adherence to the approved `DESIGN.md` tokens.
- **Dark Mode:** Native Dark Mode (`Midnight Canvas`) optimized for outdoor/nighttime visibility.
- **Light Mode:** High-contrast `Slate White` daytime alternative.
- **Responsive Mobile-first UI:** Fluid constraints scaling securely across small and large phones.
- **Risk Indicator System:** Enforces the "Icon + Label + Color" rule for critical accessibility.
- **Accessibility Principles:** Readable minimum typography limits and touch targets.
- **AI Transparency:** Prominent disclaimers confirming AI suggestions are not verified facts.

## Technology Stack
- Flutter
- Dart
- GoRouter (Navigation architecture)
- Google Fonts (Typography)

## Project Structure
```
sentinel_ai/
├── lib/
│   ├── main.dart
│   ├── app.dart                   # Root router and App shell
│   ├── core/theme/                # Sentinel AI Design System tokens
│   ├── features/                  # Distinct feature modules (auth, home, map, profile, etc.)
│   └── shared/widgets/            # Reusable UI components (buttons, risk chips, empty states)
├── assets/                        # Local image and icon assets
└── .stitch/                       # Design System source-of-truth and generated screens
```

## Getting Started
1. Install the Flutter SDK (Stable).
2. Clone the repository.
3. Run `flutter pub get` to fetch dependencies.
4. Run the project using `flutter run` on an emulator or physical device.

## Environment Configuration
Secrets and environment variables **must** be supplied locally. The codebase relies on environment configs for external services (such as Maps or Auth).

To configure your environment safely:
```bash
cp .env.example .env
```
Populate the newly created `.env` file with your local keys.

## Security
- **Never commit `.env` files.**
- **Never commit API keys or Firebase configuration files (`google-services.json`).**
- **Never commit private credentials or signing keystores (`key.properties`).**
- Use `.env.example` for documentation only.

## Development Phases
- **Phase 5P** — Responsive UI implementation and validation — COMPLETE
- **Phase 5Q** — Navigation, interaction and UX audit — COMPLETE
- **Phase 6+** — Backend integration and business logic wiring — PLANNED
