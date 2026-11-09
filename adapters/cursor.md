---
name: chat-hygiene
description: >-
  Report, threshold-check, compress/expand oversized coding-agent chats (Cursor,
  Claude Code, Codex). Use for /chat-hygiene, report, preview, compress, zip,
  expand, unzip, top N, rank ranges, or when a transcript looks huge.
---

# Chat hygiene

CLI: `chat-hygiene` (`~/.local/bin/chat-hygiene`).

```text
chat-hygiene help              # full guide + examples
chat-hygiene help compress     # one topic
chat-hygiene help examples
```

Running `chat-hygiene` with no args also prints the guide.

## Naming (use these)

| Do this | Command | Means |
|---|---|---|
| See sizes | `report` / `r` / `chr` | Ranked table; title + ref are links (Cursor: file; Claude/Codex title: UI deeplink) |
| Check threshold | `check` / `c` | Undismissed offenders |
| Dry-run | `preview` / `p` | Show **from→to** paths + snip; no changes |
| Sample turns | `snip` / `x` | Head/tail to write a summary (not unzip) |
| Archive | `compress` / `zip` / `z` | Zip original → backup, write summary, leave stub |
| Undo | `expand` / `unzip` | Put chat back at **original path** from zip+manifest |
| Stop nudges | `dismiss` / `d` | Remember “no” for this id |
| Clear “no” | `undismiss` / `ud` | |
| Read the guide | `help` / `h` | Full docs + examples |

Legacy aliases still work: `compact`→compress, `extract`→snip, `restore`→expand.

## What `--summary` means

**INPUT file** for `compress` — the ultra-squeeze `.md` you already wrote. Not a dry-run.

- Single: `chat-hygiene compress b4efd1ad --summary /tmp/one.md`
- Batch: `chat-hygiene compress --top 3 --summary-dir /tmp/summaries`

Use **`preview`** to inspect without moving anything.

## Backup manifest (for expand)

Every compress writes:

1. Inside the zip: `CHAT_HYGIENE_MANIFEST.json`
2. Sidecar next to the zip: `<same>.manifest.json`

Fields include `original_path`, `original_jsonl_path`, `backup_zip`, `summary_path`, title, sizes. The summary and stub also record **from→to**.

```text
chat-hygiene expand --zip ~/Documents/chat-archives/.../chat-id-YYYYMMDD.zip
```

## Batches

```text
chat-hygiene preview --top 3
chat-hygiene compress --rank 1-3 --summary-dir ~/tmp/ch-summaries
chat-hygiene dismiss --rank 1-3
```

## Nudge protocol (mandatory)

1. `chat-hygiene check`
2. Ask once per undismissed offender
3. dismiss → `dismiss <ref>`
4. compress → preview/snip → write summary → `compress … --summary` / `--summary-dir`
5. NEVER compress/expand/dismiss without explicit yes

Threshold: folder ≥ 2 MiB **or** jsonl ≥ 1 MiB.
