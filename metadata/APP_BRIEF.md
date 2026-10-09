<!-- gf-brief source=75c1bcb6093f97294b681311c2e084eb4aa2189676546a28f4ff29f0d4a3efd6 written=2026-10-09T13:29:13+03:00 -->
# Chickolox
## What it is
Chickolox is a session board for coaches. For each client you write a Goal and a Reality, add Options, star one path as the Will, then file that session on this device. It is for coaches and facilitators who want those notes on the phone they are holding, not in a shared notebook.

## Launch and onboarding
A cold launch shows a system launch screen with no app copy, then an unlabeled spinner.

If onboarding has not been finished, three pages appear with dots, **Skip** at the top right, and a bottom button that reads **Next** on the first two pages and **Continue** on the last. **Skip** on any page, or **Continue** on the last page, finishes onboarding and opens the board.

1. **A board for one session.** — *Goal and reality stay on this device, with the client you picked.*
2. **Ground, then branch.** — *Lock Goal and Reality before options and will can move.*
3. **Seal files the will.** — *Two options, one starred path, then the next board opens.*

On a device, the board then shows **Client records are sealed.** with *Unlock, then pick a client.* and **Continue**. That tap asks the system to confirm it is you, using the reason **Confirm it is you before client names appear.** After that succeeds, an empty roster shows **No client on the tray yet.** with *Add a client, then ground today's goal and reality.* and **Add a client**.

On the Simulator, a first launch can skip onboarding and that unlock and open a populated board (see Starter content).

## Screens
There is no tab bar. The board stays on screen. **Clients**, **Progress**, **Path**, and **Settings** open as sheets. **Scan** opens full screen.

### Chickolox (board)
Title on the board: **Chickolox**.

Tool row:

- **Clients** — opens the Clients sheet.
- **Progress** — opens the Progress sheet.
- **Path** — opens the Path sheet.
- **Scan** — opens Desk code.
- **Settings** — opens the Settings sheet.

A tray of client name buttons sits under the tools (a row on iPhone, a leading column on iPad). Tapping a name opens that client's current unfiled board, or a new blank board if the last one was filed.

When a client is open:

- The large title is the client name, or **Today's session** if none matches.
- The line under the name is one of: **Ground this goal and reality.** / **Add two options, then star one path.** / **Seal the starred path.** / **This session is filed.** / **Pick a client.**
- A strip shows a day count (or **None**) with **days since the last seal** or **No seal filed yet.**, plus **N filed**.
- **GOAL** plate with field placeholder **Goal**. Editable only before Ground.
- **REALITY** plate with field placeholder **Reality**. Editable only before Ground.
- **OPTIONS** — each added line is a button. Tapping one stars it; a **Will** chip marks the starred line. A field **Add an option line** and **Add** append a line. A caption reads **N options**.
- **WILL** — **Star one option as the path.** until a line is starred, then that line. A stepper reads **Readiness N of 5** (1 through 5).
- Notices from refused or finished steps appear under the board (exact lines in Behaviours).
- **Ground** is the live bottom button on a draft. It locks Goal and Reality.
- After Ground, **Ground** is replaced by **Seal**. **Seal** files the starred Will and opens the next blank board for the same client. It stays dim until the board has at least two options.
- **Retract** appears once any session is filed. It peels the last seal if the next board is still empty.

Empty and lock states on this screen:

- **The chart could not be read.** plus a recovery line and **Try again**.
- **Client records are sealed.** / *Unlock, then pick a client.* (or **Face ID did not confirm. Try again.**) / **Continue**.
- **No client on the tray yet.** / *Add a client, then ground today's goal and reality.* / **Add a client** — opens Clients.

### Clients
Navigation title: **Clients**.

After the same unlock as the board:

- **The roster could not be read.** plus a recovery line and **Try again**.
- **Client records are sealed.** / *Unlock, then pick a client.* (or **Face ID did not confirm. Try again.**) / **Continue**.
- **The tray is empty.** / *Add a client, or scan a desk code.* / **Scan a desk** — opens Desk code. There is no name field on this empty page.

Once at least one client exists, a list shows each name and **N desk digits**. Tapping a row opens that client's board and closes the sheet.

Section **Add a client**:

- **Name**
- **Desk digits** (digits only)
- **Add client** — needs a name; then **Client added. Their board is open.**
- Empty name shows **Write a name first.**

**Scan a desk** opens Desk code.

### Progress
Navigation title: **Progress**.

- **Progress could not be read.** plus a recovery line and **Try again**.
- **No session is filed yet.** / *Seal a will on the board, then it shows up here.* / **Close**.

When sessions exist, a summary line reads **{name}: {will}. {N} days since the last seal.** Each row shows the client name (or **Client**), the Will, **Readiness N of 5**, and **N days since this seal**.

### Path
Navigation title: **Path**. Close control is labeled **Close**.

Hero line: **Ground, then branch.** Under it, one of:

- **This board is still a draft. Ground is the live tap.**
- **Reality is locked. Add option lines next.**
- **The board is branched. Star a will, then Seal.**
- **The last board is sealed.**

Rows (the current one is titled **{name}, current**):

- **Draft** — *Goal and reality take ink.*
- **Grounded** — *Both plates are locked.*
- **Branched** — *At least two options exist.*
- **Sealed** — *The will is filed and the next board is open.*

### Desk code
Title: **Desk code**. Close control is labeled **Close**.

- Field **Type desk digits**.
- **Open desk** — matches a client and opens their board, or files a new client named **Client N** when the digits are new, or shows **That code is not on this device.**

Camera, first time: **A desk code can open the matching board.** and **Continue**, then the system camera alert.

Camera off: **The camera is off for Gradus. Open Settings, or type the digits.** and **Open Settings**.

Camera unavailable: **The camera is not available. Type the digits instead.**

On the Simulator there is no live camera. The preview reads **Type a desk code, or tap a chip.** Chips are existing client names and act like a successful scan.

### Settings
Navigation title: **Settings**.

- **Settings could not load the chart.** plus a recovery line and **Try again**.
- If nothing is stored: **Nothing is stored yet. Ground a session, then export it from here.**

Section **Contact**: **Contact Gradus** — opens the support page.

Section **Sessions**: **Export sealed sessions** — opens the system save sheet (suggested name Gradus-sessions) for a local PDF of filed sessions. Dimmed until a session is filed. Failure shows **The PDF could not be saved. Try again.** The PDF uses headings **Goal**, **Reality**, **Options**, **Will**, and **Readiness N of 5**. A PDF with no sessions would read **No sealed sessions yet.**

Also:

- **Show onboarding again** — closes Settings and replays the three pages. Clients and filed sessions stay.
- **Erase roster** — confirm title **Erase the roster?** with *Clients, boards, and sealed sessions leave this device.*, then **Erase roster** or **Cancel**. Confirming wipes the roster and returns to onboarding.

## Features
- Onboarding that states the board stays on this device, then Ground, then Seal.
- Unlock before client names appear.
- A client tray and a Clients list with name and desk digits.
- A four-plate session board: Goal, Reality, Options, Will.
- Ground locks Goal and Reality.
- Option lines; one starred path becomes the Will.
- Readiness from 1 to 5.
- Seal files the session and opens the next board.
- Retract peels the last seal while the next board is empty.
- Path: Draft, Grounded, Branched, Sealed.
- Progress: filed Wills, readiness, and days since each seal.
- Desk code: camera or typed digits.
- Export sealed sessions.
- Contact Gradus.
- Show onboarding again.
- Erase roster.

## Behaviours that can look like bugs
- After onboarding on a device, **Continue** on **Client records are sealed.** does nothing useful until the system unlock succeeds. Failure replaces the line with **Face ID did not confirm. Try again.** Tap **Continue** again.
- **Add a client** on an empty board opens Clients, but an empty Clients page only offers **Scan a desk**. The first client is created from a desk code (scan or **Type desk digits** plus **Open desk**), not from the **Name** field. The **Name** / **Add client** fields appear only after one client already exists.
- **Open desk** or a scan with no 8–14 digit run shows **That code is not on this device.** Type or scan a longer digit run.
- **Add client** with a blank name shows **Write a name first.**
- **Goal** and **Reality** stop taking text after Ground. A refused edit shows **Goal and Reality stay locked after Ground.**
- **Ground** without both plates filled shows **Write both Goal and Reality, then Ground.** Fill both, then tap **Ground** again.
- Options stay dim until Ground. A refused add shows **Ground Goal and Reality before option.**
- **Add** with an empty option field shows **Write an option line first.**
- Option lines cannot be starred until there are two. A refused star shows **Add a second option, then star a will.**
- After Ground, **Seal** is visible but dim until there are two options. A tap too early shows **Branch at least two options before Seal.**
- **Seal** with two options but no star shows **Star one option as Will, then Seal.** Tap an option line so the **Will** chip appears.
- **Seal** files the session and replaces the board with a blank one for the same client. That loop is intended. The filed session is on Progress.
- **Retract** does nothing useful if you already wrote on the next board or moved off it. The line is **Retract only while the next board is empty.** Leave the new Goal and Reality blank, or finish a new session instead.
- **Export sealed sessions** stays dim until **N filed** is at least 1.
- **Try again** on **The chart could not be read.** / **The roster could not be read.** / **Progress could not be read.** / **Settings could not load the chart.** reloads. Recovery lines you may see: **The chart was unreadable. Restored the previous copy.** and **The chart was unreadable. Started from an empty roster.**

## Starter content and resume
On a device, none. After onboarding and unlock the tray is empty.

On the Simulator, a first launch can seed four clients — **Mira Calder**, **Jonah Peck**, **Adele Voss**, **Chris Lang** — skip onboarding and unlock, file two sessions (**Ship the brief before Friday.** / **Hold a quieter one to one.**), and leave Mira's open board already written: **Name the next promotion case in one sentence.** and **The case is still a list of tasks, not a story.**

Unfinished boards resume. Choosing a client returns to their open unfiled board. Work is still there after the app is sent to the background or opened again. **Show onboarding again** does not clear work. **Erase roster** does.

## Permissions
Camera, when you open Desk code for the first time and tap **Continue**: **Gradus uses the camera to read a desk QR and open that coachee's canvas.**

Face ID, when you tap **Continue** on **Client records are sealed.**: **Gradus uses Face ID so client names stay sealed until you confirm it is you.** The system reason is **Confirm it is you before client names appear.** A device without Face ID asks for the device passcode with that same reason.

## Absent
Login or accounts, in-app purchase, ads, analytics, an account deletion flow, and the App Tracking Transparency prompt. The coach types private client names and session notes; there is no public feed.

## Data and support
Data stays on this device. Onboarding says goal and reality stay on this device. **Erase roster** states that clients, boards, and sealed sessions leave this device.

On-screen support control: **Contact Gradus**.

## Scanning and health
The app reads a desk QR (or typed desk digits) to open or add a client. It expects a desk code whose digits match a client, or a new digit run that creates **Client N**.

It does not show health, medical, or product-health information. **Readiness N of 5** is session readiness, not a medical score. Citations: None.

## Platform
English copy only. No region-specific catalog. Whole numbers follow the device's decimal format without grouping.

Portrait only, on iPhone and iPad. Dark appearance. Full screen on iPad. Minimum iOS 17.0.

## Category
Productivity
