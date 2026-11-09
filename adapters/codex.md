# Chat hygiene (Codex)

CLI: `chat-hygiene`. Preferred verbs: **compress** / **expand** (aliases: zip / unzip).

Start here: `chat-hygiene help` (or `chat-hygiene help examples`).

| Ask | Run |
|---|---|
| guide | `chat-hygiene help` |
| report | `chat-hygiene r` |
| dry-run top 3 | `chat-hygiene preview --top 3` |
| compress ranks 1-5 | write `<id>.md` → `chat-hygiene compress --rank 1-5 --summary-dir DIR` |
| undo / restore | `chat-hygiene expand --zip PATH` |
| dismiss | `chat-hygiene dismiss <ref>` |

`--summary` is an **INPUT** markdown path. Use `preview` to inspect without changes.

Each compress writes `CHAT_HYGIENE_MANIFEST.json` (inside zip + sidecar) with `original_path` so expand can undo.

Never compress/expand/dismiss without an explicit yes.
