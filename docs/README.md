# Documentation map

| Folder | What goes here |
| --- | --- |
| [`research/`](research/) | Research log (what was looked at, when, what was learned) and a list of cited sources. |
| [`inventory/`](inventory/) | A record of every original material the user supplies — names, versions, sizes, SHA-256 hashes. **Metadata only, never the files themselves.** |
| [`legal/`](legal/) | Rights, provenance, and the rules for handling original game material. |
| [`decisions/`](decisions/) | One file per approved technical or project decision ("architecture decision records"). |
| [`technical/`](technical/) | Findings about how the original game works: install layout, executable, data file formats, dependencies. |
| [`testing/`](testing/) | Test plans, and the template the user fills in after playtesting a build. |
| [`reviews/`](reviews/) | Independent audits of agent work and the status of each recommendation. |

## Research now available

- [Chris Heimlich source register](research/sources.md) — seven cited sources (six original-port-analysis articles plus the author's roadmap), with access dates and evidence caveats.
- [Research log](research/research-log.md) — the 2026-10-15 review and open technical questions.
- [PH format extraction](technical/ph-resource-formats.md) — reported headers, sprite formats, background tile fields and flags, entity record layouts, and Claude validation tasks.
- [Chris Heimlich request checklist](research/chris-heimlich-request-list.md) — questions about his private MATLAB project, naming maps, compatibility findings, and permission to use code.

These are notes **from published research**, not independently validated against a recovered retail PC build. Do not commit original game files or asset dumps.

Current project state lives in [`../PROJECT_STATUS.md`](../PROJECT_STATUS.md). Agent rules live in [`../CLAUDE.md`](../CLAUDE.md).
