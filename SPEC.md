# Gradus — Build Specification

> Portfolio app 167, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Run GROW coaching sessions on a four-quadrant board and keep the notes on this device.

| Field | Value |
| --- | --- |
| Product name | Gradus |
| Bundle identifier | `com.gradus.canvas` |
| Domain | https://gradus-canvas.pro |
| Contact URL | https://gradus-canvas.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `grd_` |
| User-Agent | `Gradus/1.0 (iOS; +https://gradus-canvas.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Gradus -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A coach grounds a coachee's Goal and Reality, branches at least two Options, and seals the chosen Will so today's session files on the device.

### 2.1 User flow

1. Unlock the roster with Face ID and open today's coachee canvas from the tray.
2. Tap Ground to lock the seeded Goal and Reality quadrants before anything else moves.
3. Add two or more Option lines in the unlocked lower half of the board.
4. Star one Option as Will, set readiness from 1 to 5, and tap Seal to file the session.
5. Open Progress from the sheet chrome to read sealed sessions and days since the last Seal.
6. Scan a desk QR on a new coachee card to jump straight to their blank canvas.

### 2.2 Essential behaviour

- Four-quadrant GROW canvas with tray of coachees and Metal-lit active quadrant
- Ground gate: Options and Will stay read-only until Goal and Reality both hold ink and Ground succeeds
- Option lines with OptionMarks; Seal requires at least two options and a starred Will
- Face ID lock on the client roster and debounced UserDefaults practice store
- Progress sheet: sealed SessionNotes, readiness scores, and days-since timeline
- Retract peels the last SealMark while the next canvas is still empty
- Local PDF export of sealed sessions from Settings
- Desk QR scan via AVCaptureMetadataOutput to focus a coachee without typing

---

## 3. Uniqueness assignment for Gradus

| Axis | Assigned value |
| --- | --- |
| Architecture | **GROW ADT fold (Draft | Grounded | Branched | Sealed); the canvas is a fold over Quadrants; Ground writes a GroundMark when Goal and Reality both hold ink and folds Draft to Grounded; each Option line writes an OptionMark and folds Grounded to Branched when at least two OptionMarks exist; Seal writes a SealMark when Will holds a starred path and folds Branched to Sealed; Ground with a missing quadrant writes ThinMark; Options or Will edits before Grounded write EarlyMark; Seal with no starred Will writes Aimless; Retract peels the last SealMark while the successor canvas is empty; a second Ground on Grounded is refused; empty canvas writes Blank** |
| UI approach | **SwiftUI Metal shaders · canvas-first** |
| Naming convention | **Coaching ladder / GROW lexicon** |
| File organization | **By canvas role (Canvas, Quadrant, GroundMark, OptionMark, SealMark, Coachee, Aimless, ThinMark, EarlyMark)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **levels · tray-plus-canvas · branded** |
| Typography | **Baskerville** |
| Navigation pattern | **Quadrant-locked chrome (the GROW board never leaves; Clients, Progress and Settings arrive as sheets; ground and seal fuse on Canvas; Face ID gates the roster; no tab bar)** |
| AI art style | **Art Deco poster · abstract** |
| Functional twist | **Ground-then-branch (Goal and Reality must Ground before Options and Will unlock; at least two OptionMarks before Seal; Seal freezes SessionNote and opens the next canvas; EarlyMark on pre-Ground edits; Aimless on empty Will; seed inks Goal and Reality so Ground is the first live tap)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — session_notes

**Core** — A coach grounds a coachee's Goal and Reality, branches at least two Options, and seals the chosen Will so today's session files on the device.

**Audience** — Coaches and facilitators who run GROW sessions and refuse to store client notes in a chat or cloud notebook app.

**User flow**

1. Unlock the roster with Face ID and open today's coachee canvas from the tray.
2. Tap Ground to lock the seeded Goal and Reality quadrants before anything else moves.
3. Add two or more Option lines in the unlocked lower half of the board.
4. Star one Option as Will, set readiness from 1 to 5, and tap Seal to file the session.
5. Open Progress from the sheet chrome to read sealed sessions and days since the last Seal.
6. Scan a desk QR on a new coachee card to jump straight to their blank canvas.

**Essential features**

- Four-quadrant GROW canvas with tray of coachees and Metal-lit active quadrant
- Ground gate: Options and Will stay read-only until Goal and Reality both hold ink and Ground succeeds
- Option lines with OptionMarks; Seal requires at least two options and a starred Will
- Face ID lock on the client roster and debounced UserDefaults practice store
- Progress sheet: sealed SessionNotes, readiness scores, and days-since timeline
- Retract peels the last SealMark while the next canvas is still empty
- Local PDF export of sealed sessions from Settings
- Desk QR scan via AVCaptureMetadataOutput to focus a coachee without typing

**Twist** — Ground-then-branch. Home is the open GROW canvas for the selected coachee. Goal and Reality accept ink in Draft. Ground writes a GroundMark only when both quadrants hold text and folds Draft to Grounded; Options and Will stay dim until Grounded. Each Option line writes an OptionMark; Will accepts exactly one starred path while Grounded with at least two OptionMarks. Seal writes a SealMark, freezes a SessionNote, stamps readiness 1 to 5, and opens the next blank canvas. Ground with a missing quadrant writes ThinMark and keeps Draft. Options or Will edits before Grounded write EarlyMark and are refused. Seal with no starred Will writes Aimless and keeps Branched. Retract peels the last SealMark while the new canvas is empty. A second Ground on Grounded is refused. Seed already inks Goal and Reality so the opening tap is Ground. Home verbs: ground-the-reality and seal-the-will, not sign-the-chart. Local only.

**Why this is not a repeat** — Paraph already ships SOAP Sign-then-advance on lane charts for therapists. Gradus files GROW coaching with a different home verb: Ground locks Reality before brainstorming Options, then Seal files Will only after two branches. Same family and local-only constraint, different quadrant model, architecture fold, navigation, and lexicon.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Split view: clients | note timeline. Face ID gate.
- Invariant: SOAP/GROW/DAP: sections.count must match titles. Mood+progress 1…5. Next-session summary = latest note + days since.
- Never: No ThreadRecall quiz as a product tab. Local only.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Each coachee canvas is a fold over four quadrants whose phase is the algebraic type Draft, Grounded, Branched, or Sealed, and views observe that one Canvas. Ground writes a GroundMark and folds Draft to Grounded only when goal and reality both hold ink, while a missing quadrant writes ThinMark and leaves Draft, and a second Ground on Grounded is refused. Each option line writes an OptionMark and the phase folds Grounded to Branched once at least two OptionMarks exist, and will holds at most one starred path. Seal writes a SealMark, freezes a SessionNote with readiness from 1 to 5, and opens the next blank canvas only from Branched with a starred path, while Seal without a star writes Aimless and keeps Branched. Option or will edits before Grounded write EarlyMark and are refused, Retract peels the last SealMark only while the successor canvas is still empty, and an empty canvas writes Blank. Unit tests cover every fold above and the session notes invariant that section count matches the four quadrant titles, readiness stays inside 1 to 5, and the next-session summary equals the latest SessionNote plus days since the last Seal.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

SwiftUI is canvas-first. Home is the GROW board, with a docked coachee tray whose column structure differs from the quadrant layout: goal is the large upper plate, reality sits beside it at a lesser width, options are lines, and will is one starred row. The only custom draw is one Metal shader on the active quadrant of Canvas, a stepped fan sheen sampled from DesignTokens. Sheets, forms, onboarding, and settings use stock List, Form, Button, TextField, and Toggle. The scan cover uses one UIViewRepresentable for the capture preview and a procedural SwiftUI reticle, with no second shader. Colours, type, space, and radius each come from one accessor. Radii stay the kit pair 18 and 8, with one shadow and filled capsules. Accent hits only the live verb, Ground or Seal. Retract and erase use a destructive button style, not accent painted as a warning. Button styles implement default, pressed, disabled, and loading. Rows and plates implement default, pressed, focused, disabled, loading, error, and selected. Hit targets fill the control, use contentShape, and stay at least 44 points. Grouped reveals step 50ms and finish within 360ms. Reduce Motion fades the group in at once and skips travel. One haptic fires on a successful Ground or Seal, and none on opening a sheet. VoiceOver labels every icon-only control. Readiness uses digits plus the word, never colour alone. Empty roster and empty progress are full-page states with cutout art, one headline, one line, and a full-width bottom button. Background fills the safe area. On iPad the tray leads and the board uses the remaining width. Copy is warm and brief, with periods or commas, and with no emoji.

### 3.3 Naming contract

Convention: Coaching ladder / GROW lexicon.

Examples to follow: Canvas.groundTheReality(), Canvas.sealTheWill(readiness:), OptionMark.starAsWill, Coachee.daysSinceSeal

### 3.4 Dependency contract

Zero external dependencies. project.yml has no packages key, no CocoaPods, no vendored source, and no bundled font. Apple frameworks only: SwiftUI for the board and sheets, Metal for the single quadrant shader, UIKit for the capture preview bridge, Core Graphics and PDFKit for a local sealed-session PDF, AVFoundation for the live desk QR session, LocalAuthentication for the roster gate, and Foundation for Codable, NumberFormatter, and Calendar. URLSession is the only permitted networking stack and it performs no requests. The assigned cgi search endpoint is unused. Do not call a remote catalog, do not add a food search, and do not add a web view. The user agent string is defined and never sent. Desk QR codes resolve against the on-device roster.

### 3.5 Navigation contract

Quadrant-locked chrome. The GROW board never leaves the root, and there is no tab bar. Ground, option entry, star, readiness, and Seal fuse on Canvas. Clients, Progress, and Settings arrive as sheets. Scan arrives as a full-screen cover. Face ID runs before roster names appear in the tray or the Clients sheet, using the system prompt, with Continue only if a preface exists. After onboarding completes, read launch arguments once. The today key shows Canvas with Ground enabled. The log key shows the Progress sheet. The goals key shows the Clients sheet. The settings key shows the Settings sheet. The scan key shows the Scan cover. Those five presentations are different surfaces. Simulator seed marks onboarding complete and treats the roster as already passed so those keys are reachable.

### 3.6 Screen composition contract

Canvas-root fused GROW (Canvas holds the four quadrants and fused ground, option, and seal controls; Clients and Progress arrive as sheets; Settings as a sheet; Scan is a full-screen cover for desk QR; Face ID before roster; no TabView)
Physical screens: Canvas, Clients, Progress, Settings, Scan, Onboarding.
Canvas is the session surface and the home mechanic, so the family session destination is not a second page. Onboarding is three or four pages with a full-width Continue or Next at the bottom, and Skip still writes defaults. Clients is the roster sheet behind Face ID, with add and a path into Scan. Progress lists sealed SessionNotes, readiness, and days since the last Seal, and its summary line is the latest note plus that day count. Settings holds the contact link https://gradus-canvas.pro/contact-us, local PDF export of sealed sessions, re-run onboarding, and a confirmed erase of the roster. Scan is the desk QR cover. The locked roster empty state reads Client records are sealed, then Unlock, then pick a client, with Continue at the bottom. A populated simulator launch shows several coachees and an inked board, not one stub row.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By canvas role (Canvas, Quadrant, GroundMark, OptionMark, SealMark, Coachee, Aimless, ThinMark, EarlyMark)**

```
Gradus/
  DesignTokens.swift
Canvas/Canvas.swift
Canvas/Quadrant.swift
Canvas/CanvasPhase.swift
Marks/GroundMark.swift
Marks/OptionMark.swift
Marks/SealMark.swift
Marks/ThinMark.swift
Marks/EarlyMark.swift
Marks/Aimless.swift
Marks/BlankMark.swift
Coachee/Coachee.swift
Coachee/SessionNote.swift
Store/ChartRecord.swift
Store/PracticeStore.swift
Screens/CanvasRootView.swift
Screens/ClientsSheet.swift
Screens/ProgressSheet.swift
Screens/SettingsSheet.swift
Screens/ScanCover.swift
Screens/OnboardingView.swift
Design/TypeScale.swift
Design/QuadrantShader.metal
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Clients
A first-class screen for **Clients**. Must render empty, populated and error states.

### 5.3 Session
A first-class screen for **Session**. Must render empty, populated and error states.

### 5.4 Progress
A first-class screen for **Progress**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Client** — named per this app's convention.
- **SessionNote** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **levels · tray-plus-canvas · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#111827` | Screen background |
| `surface` | `#2D3340` | Cards, rows, sheets |
| `ink` | `#FFFFFF` | Primary text and icons |
| `accent` | `#D97706` | Primary action, key figure, progress fill |
| `muted` | `#ABAEB3` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Gradus/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Baskerville**

Baskerville only, through one accessor of six Dynamic Type steps: display, title, headline, body, caption, and micro. Body is about 17 points. Display is short and wide, usually one or two lines, for the coachee name. The type move is poster small caps: the four quadrant names use Baskerville with wide tracking and stay on one line. Baskerville italic is the single playful moment, used only on the starred will line. Readiness, option counts, and days since the last Seal go through NumberFormatter with monospaced digits so old-style figures do not shift. Sizes use relative text styles and ScaledMetric, with no fixedSize and nothing under 12 points. At the largest accessibility size the board reflows and names truncate, still in Baskerville, and headlines are not clipped. Day edges use Calendar.current.startOfDay before the YYYYMMDD integer.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **8pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI Metal shaders · canvas-first**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI Metal shaders · canvas-first** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **levels** — steal rhythm and restraint, not their colours or logos.

Mood: **Conversion-focused design that removes friction and guides users toward action through clarity, trust, and speed.**.

Home rhythm (`tray-plus-canvas`, dense): Tray of materials, canvas of the work.

High-end agency: huge type, air, one accent, hairline depth. Layout `tray-plus-canvas`, density dense. Kit 18/8, shadow, filled capsule. Palette recipe `branded`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Soft rounded UI type, one playful moment, no serif. Reference type feel: agency.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

One Codable ChartRecord, schemaVersion from 1, is encoded as JSON under the single UserDefaults key grd.chart.v1. Its five collections keep the axis names and hold this product: islands is the coachee roster with name and desk digit run, books is the canvases with goal ink, reality ink, phase, and coachee id, sessions is the sealed SessionNotes with frozen quadrant text, readiness from 1 to 5, and daykey, runs is the open canvas pointer plus the ordered mark log of GroundMark, OptionMark, SealMark, ThinMark, EarlyMark, Aimless, and Blank, and rhumbs is the option lines with at most one starred will. Those collection names are storage fields. Domain types stay Canvas, Quadrant, Coachee, and the mark types. PracticeStore holds the record in memory and is the source of truth. Views never touch UserDefaults. Every edit and every mark schedules one debounced save about 400ms later, with an immediate flush when scenePhase becomes inactive or background and after Seal, Retract, or resetAllData. Day keys are Int YYYYMMDD from Calendar.current.startOfDay, never Date as a dictionary key. Decode failure restores grd.chart.v1.backup, then an empty record, and never crashes. resetAllData is reachable from Settings. Simulator seed runs once behind grd.demo.v1, marks onboarding complete, files several coachees and at least two sealed notes, and leaves the open canvas in Draft with goal and reality already inked so Ground is enabled. Never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Gradus/1.0 (iOS; +https://gradus-canvas.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.productivity`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.productivity
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Ground-then-branch (Goal and Reality must Ground before Options and Will unlock; at least two OptionMarks before Seal; Seal freezes SessionNote and opens the next canvas; EarlyMark on pre-Ground edits; Aimless on empty Will; seed inks Goal and Reality so Ground is the first live tap)

Home is the open GROW canvas for the selected coachee, and the seed already inks goal and reality so the first live tap is Ground. Ground writes a GroundMark only when both upper quadrants hold text and then folds Draft to Grounded, while options and will stay dim and read-only until that mark exists. Option or will edits in Draft write EarlyMark and are refused, and a ground with a missing quadrant writes ThinMark without leaving Draft. After Grounded, each option line writes an OptionMark, will stars exactly one path once two OptionMarks exist, and Seal writes a SealMark that freezes the SessionNote, stamps readiness from 1 to 5, and opens a blank canvas. Seal without a starred will writes Aimless and stays Branched, Retract peels the last SealMark only while that new canvas is empty, and a second Ground on Grounded is refused. The board verbs are Ground and Seal, and every note stays on this device.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Art Deco poster · abstract**


Base prompt, reused and extended for every asset:

```
Art Deco poster, abstract and graphic, flat planes, stepped arches, fan rays, and hairline rules. Symmetrical ornament with one dominant solid mass, not a row of equal panels. No lettering, no numerals, no photoreal people, no clay, no glass, no 3D render. Mood is ceremonial and calm, like a printed announcement. Use only the app palette already chosen. Do not name hues.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `grd_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `grd_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `grd_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `grd_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `grd_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `grd_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `grd_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `grd_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `grd_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `grd_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `grd_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Ground-then-branch (Goal and Reality must Ground before Options and Will unlock; at least two OptionMarks before Seal; Seal freezes SessionNote and opens the next canvas; EarlyMark on pre-Ground edits; Aimless on empty Will; seed inks Goal and Reality so Ground is the first live tap)' feature screen. |
| 11 | `grd_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `grd_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`grd_AppIcon`** — 1024x1024

```
Art Deco poster emblem of a stepped fan rising out of a four-part square, one solid mass centered and filling the canvas edge to edge, no text, no numerals, no rounded mask, no drop shadow, abstract flat planes.
```

**`grd_Splash`** — 1290x2796

```
Vertical Art Deco poster filling the frame, stepped arch and hairline rules, quiet uncluttered centre band, abstract flat planes, no text, no floating cutout.
```

**`grd_Onboarding1`** — 1024x1536

```
Solid four-panel folding board standing upright, Art Deco stepped corners, opaque painted planes, one object, abstract, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_Onboarding2`** — 1024x1536

```
Solid hand pressing a thick disc seal onto the lower panel of a board, mid gesture, opaque Art Deco poster forms, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_Onboarding3`** — 1024x1536

```
Solid stack of sealed session cards fanned in a stepped arc, opaque paper planes, Art Deco edges, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_EmptyHome`** — 1024x1024

```
Solid closed folio standing upright, thick opaque cover, Art Deco border as part of the object, calm and unused, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_EmptyList`** — 1024x1024

```
Solid empty tray with a stepped lip, opaque, nothing inside, Art Deco poster object, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_CardBackdrop`** — 1200x800

```
Wide abstract Art Deco field of hairline fans and stepped rules, low contrast, filling the canvas edge to edge so type can sit on it, no letters, no cutout subject.
```

**`grd_ControlFace`** — 512x512

```
Solid stepped disc with thick tick blocks built into the body, a readiness dial as one opaque object, Art Deco poster, not a wire ring, no numerals, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_TwistHero`** — 1024x1024

```
Solid four-quadrant plaque, upper block larger, lower half two branching bars with one bar marked by a small solid star shape, opaque Art Deco poster, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_SuccessMark`** — 512x512

```
Solid filled disc with a short stepped chevron in the mass, metal or ceramic, occupying the centre, not an outline, not a hollow ring, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`grd_HeaderDecor`** — 1200x600

```
Wide solid fan ornament with a hairline bar along its lower edge, horizontal Art Deco poster piece, opaque subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`grd.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `GradusTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Gradus/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Gradus -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **GROW ADT fold (Draft | Grounded | Branched | Sealed); the canvas is a fold over Quadrants; Ground writes a GroundMark when Goal and Reality both hold ink and folds Draft to Grounded; each Option line writes an OptionMark and folds Grounded to Branched when at least two OptionMarks exist; Seal writes a SealMark when Will holds a starred path and folds Branched to Sealed; Ground with a missing quadrant writes ThinMark; Options or Will edits before Grounded write EarlyMark; Seal with no starred Will writes Aimless; Retract peels the last SealMark while the successor canvas is empty; a second Ground on Grounded is refused; empty canvas writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI Metal shaders · canvas-first**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Quadrant-locked chrome (the GROW board never leaves; Clients, Progress and Settings arrive as sheets; ground and seal fuse on Canvas; Face ID gates the roster; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Baskerville** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Gradus
xcodegen generate
xcodebuild build-for-testing -scheme Gradus -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.gradus.canvas/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Gradus -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.gradus.canvas/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Gradus -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.gradus.canvas/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
