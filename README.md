# Gradus

Gradus is a local GROW board for coaches who will not put client notes in a chat or a cloud notebook. A coach picks a coachee, grounds Goal and Reality, adds at least two Options, stars one as Will, and seals the session on the device.

## Architecture

Each coachee canvas is a fold over four quadrants. The phase is an algebraic type: Draft, Grounded, Branched, or Sealed. Views observe one `Canvas` and send verbs to `PracticeStore`. They do not invent a second state machine.

Ground writes a `GroundMark` and folds Draft to Grounded only when Goal and Reality both hold ink. A missing quadrant writes `ThinMark` and stays Draft. A second Ground on Grounded is refused. Each option line writes an `OptionMark` and the phase folds to Branched once two exist. Seal writes a `SealMark`, freezes a `SessionNote` with readiness from 1 to 5, and opens the next blank canvas, which writes `Blank`. Seal without a starred Will writes `Aimless` and stays Branched. Option or Will edits before Grounded write `EarlyMark` and are refused. Retract peels the last `SealMark` only while the successor canvas is empty.

The fold fits this product because a GROW session is a gate, not a form. Options and Will are meaningless until Reality is locked, and the phase makes that rule impossible to skip in the UI.

## Unique feature

Ground-then-branch. Home is the open canvas, not a list of notes. Seed ink already fills Goal and Reality so the first live tap is Ground. The ladder sheet shows the same phase beside the board. Progress reads the latest sealed note plus days since that seal.

## Art

Style: Art Deco poster, abstract and graphic, flat planes, stepped arches, fan rays, and hairline rules. Symmetrical ornament with one dominant solid mass, not a row of equal panels. No lettering, no numerals, no photoreal people, no clay, no glass, no 3D render. Mood is ceremonial and calm, like a printed announcement. Use only the app palette already chosen. Do not name hues.

Image sets are named in SPEC section 13.2 and filled by a later generate step. Prompts:

- grd_AppIcon: Art Deco poster emblem of a stepped fan rising out of a four-part square, one solid mass centered and filling the canvas edge to edge, no text, no numerals, no rounded mask, no drop shadow, abstract flat planes.
- grd_Splash: Vertical Art Deco poster filling the frame, stepped arch and hairline rules, quiet uncluttered centre band, abstract flat planes, no text, no floating cutout.
- grd_Onboarding1: Solid four-panel folding board standing upright, Art Deco stepped corners, opaque painted planes, one object, abstract, no text.
- grd_Onboarding2: Solid hand pressing a thick disc seal onto the lower panel of a board, mid gesture, opaque Art Deco poster forms, no text.
- grd_Onboarding3: Solid stack of sealed session cards fanned in a stepped arc, opaque paper planes, Art Deco edges, no text.
- grd_EmptyHome: Solid closed folio standing upright, thick opaque cover, Art Deco border as part of the object, calm and unused, no text.
- grd_EmptyList: Solid empty tray with a stepped lip, opaque, nothing inside, Art Deco poster object, no text.
- grd_CardBackdrop: Wide abstract Art Deco field of hairline fans and stepped rules, low contrast, filling the canvas edge to edge so type can sit on it, no letters, no cutout subject.
- grd_ControlFace: Solid stepped disc with thick tick blocks built into the body, a readiness dial as one opaque object, Art Deco poster, not a wire ring, no numerals, no text.
- grd_TwistHero: Solid four-quadrant plaque, upper block larger, lower half two branching bars with one bar marked by a small solid star shape, opaque Art Deco poster, no text.
- grd_SuccessMark: Solid filled disc with a short stepped chevron in the mass, metal or ceramic, occupying the centre, not an outline, not a hollow ring, no text.
- grd_HeaderDecor: Wide solid fan ornament with a hairline bar along its lower edge, horizontal Art Deco poster piece, opaque subject, no text.

## How this differs

Paraph files SOAP charts for therapists with sign-then-advance. Gradus files GROW coaching. Ground locks Reality before Options exist, and Seal files Will only after two branches. The home verb is ground-the-reality, then seal-the-will. Notes stay on the device.

## Build

```bash
cd apps/Gradus
xcodegen generate
xcodebuild build-for-testing -scheme Gradus -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```
