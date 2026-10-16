# Research log

Newest entries at the top. Label each finding: **Verified** (checked against a primary source or the game itself), **Reported** (author claim or secondhand), or **Assumption** (hypothesis needing evidence).

## 2026-10-15 — Review of Chris Heimlich's Original Port Analysis

- **Question:** Which parts of the Kinesoft Windows 95 resource formats have already been documented publicly, and which private materials could help Claude?
- **Sources consulted:** S001-S006 (six technical progress articles); S007 (author's roadmap). Full URLs and access dates in [sources.md](sources.md).
- **Findings:**
  - **[Verified — publication]** The six articles contain concrete format notes, MATLAB parser listings or excerpts, and examples for `INIT.PH` sound/sprite data, level sprites, backgrounds, and dynamic/static/collision data.
  - **[Reported — not verified against our own disc]** `INIT.PH` contains common assets and embedded WAV effects, whereas separate level `.PH` files contain level-specific content (S001-S003).
  - **[Reported]** Two `4.V4` sprite variants are described; the more complex format uses indexed-color palettes, row delimiters/transparency encoding and 32-bit dimensions (S002-S003). Later work interprets the last two header fields as **signed rendering X/Y offsets** (S006).
  - **[Reported]** Sprite extraction across common and level-specific segments yielded **11,568 sprites** in the author's work (S003).
  - **[Reported]** Background artwork uses **8x8 indexed tiles** and 16-bit references with tile index, flips and rendering priority flags. Parallax and animated-tile behavior remained unresolved in S004.
  - **[Reported]** Dynamic, static, and collision records are organized using a **16x16 coordinate grid**, a column-offset table and row/ID pairs. Column-offset table entries are byte-swapped in the published MATLAB parser (S005). Individual entity meanings and Y alignment are not fully known.
  - **[Reported]** The author had a consolidated, version-controlled **private MATLAB project**, a master extractor, improved asset maps, and a private GitHub page as of S006. **We have neither seen nor accessed those private materials.**
- **Extracted documentation:** [PH resource format notes](../technical/ph-resource-formats.md) (independent paraphrase; NOT a tested parser).
- **Open questions:**
  1. What exact retail release/revision and hashes did Chris analyze? Are these the same files we will recover?
  2. Can the author share the MATLAB project/scripts under explicit terms and the entity-name maps? What changed after 2021?
  3. How are `.PH` chunks classified and located robustly across all level variations?
  4. What are the precise sprite row-code edge cases, visual priority rules, and Y-grid alignment?
  5. What executable-side behavior defines collision semantics, parallax, timing and animations?
- **Follow-up:** Record a lawful game-file inventory; compare these published descriptions against sample bytes in a read-only local test; seek permission/availability of private research materials, without assuming a response.
- **Confidence:** High that these claims are present on Chris's public pages; **not independently verified** as correct for the original game binaries in our possession.

---

## Entry template

```
### YYYY-MM-DD — Short topic
- Question:
- Sources consulted: (source IDs from sources.md)
- Findings:
  - [Verified/Reported/Assumption] ...
- Open questions:
- Follow-up:
```

## Other open lead

- Andy Glaister — reported original Kinesoft developer; verify role independently. No contact has been confirmed.
