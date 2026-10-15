# CLAUDE.md — Permanent project instructions

This file gives standing instructions to any AI coding agent working in this repository.
Read it at the start of every session, then read `PROJECT_STATUS.md` for current state.

## What this project is

A faithful restoration of the **Kinesoft Windows 95 PC version** of *Pitfall: The Mayan Adventure* (Activision, 1995), made to run well on **Windows 10/11**. A browser version is a possible later phase and must never compromise the Windows restoration.

## Roles

- **The user** directs the project, makes decisions, and playtests builds.
- **The agent** does programming, technical research, documentation, and automated testing under the user's direction.

## Hard rules (do not break these)

1. **Reference version is the Kinesoft Win95 PC release only.** Never substitute behavior, assets, levels, timing, or code from the Genesis, SNES, Sega CD, 32X, Jaguar, or GBA versions. Other versions may be mentioned in research notes, clearly labeled, but are never the reference.
2. **Do not assume original source code exists or is available.** Plan as if only the shipped game files are available until proven otherwise.
3. **Never download copyrighted game files** (disc images, installers, executables, assets, music, video, manuals) from the internet. Only work with material the user supplies.
4. **Never commit original game material.** Original/proprietary files live only in `private/` (git-ignored). Check `git status` before every commit to confirm nothing proprietary is staged.
5. **Never push to GitHub without the user's explicit approval** for that specific push. Local commits are fine when the user has asked for them.
6. **Ask before major architectural decisions** — choice of language, framework, engine approach (compatibility layer vs. reimplementation), build system, asset pipeline, or any new third-party dependency. Record approved decisions in `docs/decisions/`.
7. **Do not send external communications** (emails, issues, forum posts, outreach) without explicit user authorization.
8. **Explain everything in plain English.** Avoid unexplained jargon. When a technical term is necessary, define it briefly.

## Current phase

Planning and research (see `PROJECT_STATUS.md`). **Do not start writing a game engine or reimplementation** until the user approves a technical direction. C++ with SDL3 is a *candidate only*, not a decision.

## Working practices

- **Evidence over assumption.** Label every significant claim as *verified* (with source), *reported* (secondhand), or *assumption*. Historical or developer recollections must be corroborated.
- **Originals are read-only.** Never modify user-supplied original files. Work on copies; record SHA-256 hashes in `docs/inventory/`.
- **Small, testable steps.** Each milestone should end with something the user can run or check, plus written test steps.
- **Every code change must document** how to build it, how to run it, how to test it, and what result is expected.
- **Leave a clean handoff.** At the end of a work session, update `PROJECT_STATUS.md` (milestone state, decisions, open questions, next smallest task).

## Repository layout

```
CLAUDE.md               This file — permanent agent instructions
PROJECT_STATUS.md       Living status, milestones, risks, decision summary
README.md               Public-facing project summary
docs/
  README.md             Map of the documentation
  research/             Research log and source/citation list
  inventory/            Inventory of user-supplied materials (metadata + hashes only)
  legal/                Rights, provenance, and asset-handling policy
  decisions/            Architecture decision records (one file per decision)
  technical/            File formats, executable analysis, engine notes
  testing/              Test plans and playtest report templates
private/                (git-ignored) original game files, disc images, extracted assets
```

## Environment notes (this machine)

- OS: Windows 11, shell is Windows PowerShell 5.1.
- `git` is **not on PATH**. Use GitHub Desktop's bundled copy:
  `& "$env:LOCALAPPDATA\GitHubDesktop\app-3.6.7\resources\app\git\cmd\git.exe" <args>`
  (the version folder `app-3.6.7` changes when GitHub Desktop updates — search `%LOCALAPPDATA%\GitHubDesktop` if it moves).
- Command-line git cannot authenticate to GitHub (the repo is private). Pushing/fetching is done by the user through GitHub Desktop, or after the user sets up credentials.
- Remote: `https://github.com/TheHuskinator/pitfall-pc-restoration.git`, default branch `main`.

## Documentation conventions

- Markdown, dates in `YYYY-MM-DD`.
- Decisions: `docs/decisions/NNNN-short-title.md` using `docs/decisions/0000-template.md`.
- Cite sources with title, author, URL or location, and date accessed.
