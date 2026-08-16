# Design System: Sentinel AI

## 1. Visual Theme & Atmosphere

Sentinel AI is a safety-intelligence mobile application. The atmosphere is measured, authoritative, and trustworthy - like a mission-critical operations center distilled into a premium mobile experience. The interface communicates calm intelligence under pressure: dark backgrounds that reduce eye strain in outdoor conditions, precise risk color coding that communicates immediately without alarm, and a clean spatial hierarchy that keeps safety information primary at all times.

Density: Daily App Balanced (5/10). Variance: Offset Asymmetric (6/10). Motion: Fluid CSS (5/10).

The application must feel premium, trustworthy, and intelligent - never playful, never aggressive, never generic.

## 2. Color Palette & Roles

Sentinel AI supports both Dark Mode (default, premium) and Light Mode (accessible, day-time).

### Dark Mode (Primary)
- **Midnight Canvas** (#0A0F1E) - Primary background. Deep navy.
- **Card Surface** (#111827) - Card and container fill.
- **Raised Surface** (#1C2537) - Bottom sheets, elevated panels.
- **Sentinel Blue** (#2563EB) - Primary brand color. CTAs, active navigation.
- **AI Horizon** (#0EA5E9) - AI-related features only. Sky blue.
- **Text Primary** (#F0F4FF) - Headings and primary text.
- **Text Secondary** (#8B98B8) - Supporting metadata, muted.
- **Structural Border** (rgba(255,255,255,0.08)) - 1px borders.

### Light Mode (Secondary)
- **Slate White** (#F8FAFC) - Primary background. Clean, anti-glare white.
- **Pure White** (#FFFFFF) - Card and container fill.
- **Elevated Light** (#F1F5F9) - Bottom sheets, elevated panels.
- **Sentinel Blue** (#2563EB) - Primary brand color.
- **Deep Sky Blue** (#0284C7) - AI-related features.
- **Text Primary Dark** (#0F172A) - Headings and primary text.
- **Text Secondary Dark** (#64748B) - Supporting metadata.
- **Structural Border Dark** (rgba(0,0,0,0.08)) - 1px borders.

### Semantic Risk Colors (Both Modes)
Risk colors must never depend on color alone. Always combine ICON + LABEL + COLOR.
- **Risk Low:** #22C55E (Dark) / #16A34A (Light) - Safe / Low risk. Calm green.
- **Risk Medium:** #F59E0B (Dark) / #D97706 (Light) - Moderate risk. Amber.
- **Risk High:** #EF4444 (Dark) / #DC2626 (Light) - Elevated risk. Clear red.
- **Risk Critical:** #DC2626 (Dark) / #B91C1C (Light) - Maximum urgency. Deep red with pulse.
- **Success:** #10B981 (Dark) / #059669 (Light) - Resolved, success states.
- **Emergency:** #FF2D55 (Dark) / #E11D48 (Light) - Emergency button only.

## 3. Typography Rules

- **Display/App Identity:** Outfit weight 700, tracking tight.
- **Screen Titles:** Outfit weight 600.
- **Section Headings:** Outfit weight 500.
- **Body/Card Content:** Outfit weight 400, relaxed leading.
- **Labels/Badges:** Outfit weight 400, Text Secondary color.
- **Numbers/Risk Data:** JetBrains Mono weight 600. All numerical data uses monospace.
- **Minimum body size:** 14sp.
- **Banned fonts:** Inter, Roboto, any serif font in UI.

## 4. Component Stylings

**Risk Indicator Chips:** Always combine color + icon + label. Never color alone.
- Low Risk: shield_check icon, green #22C55E, "Low Risk"
- Medium Risk: warning_amber icon, amber #F59E0B, "Medium Risk"
- High Risk: gpp_bad icon, red #EF4444, "High Risk"
- Critical: emergency_home icon, red #DC2626 with pulse animation, "Critical"
- Pill shape, 8px radius, 6px/12px padding.

**Primary Buttons:** Sentinel Blue fill, Outfit 600, 48px minimum height. On press: -1px Y + pressed blue. No outer glow.

**Secondary/Ghost Buttons:** Structural Border outline, same press behavior.

**Cards:** Card Surface fill, 16px radius, 1px Structural Border, 0 4px 24px rgba(0,0,0,0.3) shadow, 16px padding.

**Bottom Sheets:** Raised Surface fill, 24px top radius, drag handle. Spring-up 200ms.

**Input Fields:** Label above. Card Surface background. Sentinel Blue 2px focus ring. Error text below in High red. No floating labels.

**Map Markers:** Risk color + sentinel shield icon. Cluster bubbles with JetBrains Mono count.

**Alert Banners:** Left 4px color bar matching risk level. Swipe to dismiss.

**Bottom Navigation:** Raised Surface. Active: Sentinel Blue. Inactive: Text Secondary. Center Report tab as elevated FAB.

**Emergency Button:** Emergency Red FAB, always visible on home, never hidden. Breathing pulse animation 3s loop.

**Loading:** Skeletal shimmer matching layout dimensions. No spinners.

**Empty States / Insufficient Data:** 
- Visual: Large subdued icon + Text Primary title + Text Secondary description + single CTA action if applicable.
- Language: Never use "This location is safe." Use accurate data descriptions: "Insufficient verified safety data is available for this location." or "No verified incidents found for this area."
- Placement: Centered in the available container/screen view.

**Error States:**
- Visual: Clear human-readable description. Retry CTA. Text in High Risk Red for critical faults.

**AI Processing / Classification:**
- AI Horizon (#0EA5E9) left border or pulse with "Analyzing..." label. 
- Must explicitly state: "AI recommendations are suggestions and are not verified facts." Do not imply final human verification.

## 5. Logo & Branding Guidelines

- **Concept:** Geometric shield combining protection, location awareness (pin dot), and AI intelligence (circuit arc/eye).
- **Style:** Minimal, clean angular lines. Not a traditional heraldic shield. 
- **Colors:** Outline in Sentinel Blue, single accent node in AI Horizon (Sky Blue). 
- **Usage:** Must scale cleanly to app icon size without losing detail. Monochrome variants required for light/dark theme adaptability.

## 5. Layout Principles

Mobile-first, single-column. 16px horizontal screen padding. Safety information is primary visual element on home.

Map screens are full-bleed with bottom sheet overlays. No overlapping text on map tiles.

Multi-step flows use progress indicator at top. Forms are single-column vertical with 16px spacing.

Every element in its own clear spatial zone. No overlapping.

## 6. Motion & Interaction

Screen transitions: horizontal slide for depth, fade for tabs.
Bottom sheet: spring-up 200ms ease-out.
Critical pulse: 2s opacity loop, transform only.
AI spinner: 1.2s rotate on AI Horizon circle.
Card press: 40ms scale 0.98 spring.
Emergency: 3s scale breathing pulse always active.
Submission success: checkmark draw + one-time confetti.
List reveal: 40ms stagger per item.
All animations: transform and opacity only.

## 7. Anti-Patterns (Banned)

- No emojis
- No Inter font
- No pure black (#000000)
- No neon glows or outer glow box-shadows
- No purple/violet accents
- No gradient text on headings
- No safety guarantee language in copy
- No overlapping elements
- No 3-column equal card grids
- No fabricated statistics or metrics
- No AI cliches (Elevate, Seamless, Unleash)
- No circular spinners
- No risk communicated by color alone (always icon + label + color)
- No emergency button hidden in menus
- No dead-end screens
