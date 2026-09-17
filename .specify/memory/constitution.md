# www.alexecollins.com Constitution

## Core Principles

These are the house rules. They are the same in every one of Alex's apps because they come
from how he works rather than from what this app does, and they are written here so a fresh
agent does not have to infer them.

### I. A rule lives in the package, with a test, before it reaches a view

A view that is deciding something is a rule nobody can test and nobody can find. Put it in
the package, give it a test, then wire the view to it. A rule Alex states out loud is a test
as much as it is code.

### II. Measure it, do not read about it

Read the log, run the command, look in the folder, drive the screen. A claim about the world
that nobody went and checked is a rumour, however confidently a file states it. This applies
hardest to what a framework's documentation says it does.

### III. Every word a person reads is Alex's

The `alex-writing-voice` skill governs every string in the app and every document filed about
it: the first-run sheet, permission primers, empty states, error lines, settings labels.
**No em dashes.** Cut hedging rather than soften it. Say why, not only what.

### IV. The phase is Alex's to move

`dev`, `devtest`, `test`, `review`, `live`, recorded in `.claude/ship-it.yml`. An agent may
move `dev` to `devtest` once the round's work is done and the reviews are clean. **Every move
after that is Alex's, in his own words**, and so is any demotion, the tier and the focus line.
The `sdlc` skill says what each phase permits.

### V. A finding is fixed or logged, never put to Alex

Blocking or major: fix it in the same round, one commit per fix, and report before and after.
Minor: log it in `BACKLOG.md` under `## Minor review findings` in the shape the `sdlc` skill
gives, so it can be queried. The exception is a finding that would change what the app *is*,
which is `CONTRIBUTING.md`'s promise and gets noted rather than acted on.

### VI. Units, dates and numbers come from the device

Language & Region decides miles or kilometres, the date order and the decimal mark. Never
assume a country. Date anything published from `date` rather than from a UTC timestamp: UTC
rolls over at 5pm Pacific, and two policy pages once went up dated tomorrow.

### VII. No instructional text on a working screen

The object explains itself. The first-run sheet is shown once and lives at the top of
Settings afterwards. A single tip only for the one gesture nobody would find. Prefer silence
to a bad sound, and a real sound to a synthesised one.

## This app's own rules

None extracted yet. `AGENTS.md` is the map of this code; anything in it that turns out to
be a rule that must not be broken belongs here, and moving it is a commit like any other.

## Spec-driven development

Adopted 17 September 2026, the same day as the rest of Alex's apps. This project runs
**GitHub Spec Kit**: `.specify/` holds this constitution and the active feature, and a piece
of work is a folder under `specs/` with `spec.md` (what is wanted), `plan.md` (how) and
`tasks.md` (the ordered work).

`.specify/feature.json` names the feature in progress, so an agent starting here can pick up
where the last one left off. It is gitignored as per-checkout state.

**A spec says what the software should do. It does not say what the agents did**: that is the
transcript, and it lives in the factory. Both matter and they are not one document.

Why Spec Kit and not the other four: it is the only one that records which feature is active.
The comparison is in `~/SoftwareFactory/docs/spec-driven-factory-design-brief.html`.

## Governance

Alex decides. An agent that cannot decide something raises it through the factory with
`escalation_raise`, giving at least two options and a recommendation, then gets on with
something else. It does not ask inside its own interface and wait, because a question asked
there reaches nobody who is not already watching that agent.

`AGENTS.md` is the map of this code and says how things work. This file says what may not be
broken while changing it. Where they disagree, this one wins and `AGENTS.md` gets corrected.

**There is no map in this repository yet**, and the two paragraphs above point at a file
nobody has written. When one is written it is `AGENTS.md`: four different CLIs work this
folder and a file named after one of them is a file the other three do not read. Claude
Code reads `CLAUDE.md` and not `AGENTS.md`, so that name goes beside it as a symlink
(`ln -s AGENTS.md CLAUDE.md`) and nothing is ever written into it: a second map can only
disagree with the first.

Amending this file is a commit like any other, with the reason in the message. A principle
here that turns out to be wrong is deleted rather than quietly ignored.

**Version**: 1.0.0 | **Ratified**: 2026-09-17 | **Last Amended**: 2026-09-17
