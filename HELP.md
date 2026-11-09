# chat-hygiene help

Portable CLI to **report**, **preview**, **compress**, and **expand** oversized
coding-agent chats (Cursor, Claude Code, Codex).

```text
chat-hygiene help              # this guide
chat-hygiene help compress     # one topic
chat-hygiene help examples     # copy-paste recipes
chat-hygiene                   # same as help
```

---

## What it does

Finds oversized coding-agent chats, reports them, and (with your OK) **compresses**
them to a zip + ultra-summary while leaving a tiny stub—and can **expand** them
back via a restore manifest.

| Command | Purpose |
|---|---|
| `report` | Ranked size table (title + ref links; Top 10 + overall totals) |
| `check` | Undismissed chats over threshold |
| `preview` / `snip` | Dry-run / sample turns (no delete) |
| `compress` / `zip` | Archive → zip + summary + stub |
| `expand` / `unzip` | Restore to original path from zip + manifest |
| `dismiss` / `undismiss` | Stop or clear nudges for a chat id |
| `help` | This guide |

Agents never compress automatically; they ask, and “no” is remembered per chat id.

Threshold (OR): **folder ≥ 2 MiB** or **main jsonl ≥ 1 MiB**.

---

## Tech stack

| Piece | Choice |
|---|---|
| Language | **Python 3** (stdlib only: `argparse`, `pathlib`, `json`, `zipfile`, `re`) |
| Shell | `install.sh` + aliases (`chr` / `chc` / `chp` / `chz`) |
| Completions | bash + zsh |
| Config | `~/.config/chat-hygiene/` (`config.toml`, `state.json`) |
| Docs | `HELP.md`, README, Cursor skill + Claude/Codex adapters |
| Dependencies | **none** (no pip packages) |

Paths are home-relative / XDG-style — nothing hard-coded to a username or project.

---

## Architecture

```text
                         ┌─────────────────────┐
                         │  You / coding agent │
                         └──────────┬──────────┘
                                    │
                         chat-hygiene <cmd>
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │   CLI  (Python 3, stdlib)     │
                    │   ~/.local/bin/chat-hygiene   │
                    └───────────────┬───────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
              ▼                     ▼                     ▼
       ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
       │  Discover   │       │   Config    │       │  Commands   │
       └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
              │                     │                     │
              │                     ▼                     │
              │            ~/.config/chat-hygiene/        │
              │              • thresholds                 │
              │              • dismissals                 │
              │                                           │
              ▼                                           ▼
   ┌────────────────────┐              ┌──────────────────────────────┐
   │ Chat stores        │   report /   │  inspect                     │
   │                    │   check  ──► │  preview · snip              │
   │ Cursor  ~/.cursor/ │              └──────────────────────────────┘
   │ Claude  ~/.claude/ │
   │ Codex   ~/.codex/  │              ┌──────────────────────────────┐
   └─────────┬──────────┘   compress ► │  1. zip original             │
             │                         │  2. write manifest (from→to) │
             │                         │  3. write ultra-summary      │
             │                         │  4. leave tiny stub in place │
             │                         └──────────────┬───────────────┘
             │                                        │
             │                                        ▼
             │                         ~/Documents/chat-archives/
             │                           <tool>/<project>/
             │                             *.zip
             │                             *.manifest.json
             │                                        │
             │◄────────────── expand ─────────────────┘
             │              (restore original_path)
             │
             ▼
   ~/.local/share/chat-hygiene/summaries/
     <tool>/<project>/<id>.md


   Thin wrappers (not core runtime)
   ────────────────────────────────
   HELP.md · skill · adapters · shell completions · templates
```

---

## Quick map

| You want to… | Run |
|---|---|
| See largest chats | `chat-hygiene report`  or  `chr`  or  `r` |
| See who is over the limit | `chat-hygiene check`  or  `chc` |
| Dry-run (no changes) | `chat-hygiene preview --top 3`  or  `chp --top 3` |
| Sample turns to write a summary | `chat-hygiene snip --rank 1` |
| Archive a chat | `chat-hygiene compress … --summary FILE`  or  `chz …` |
| Undo / put chat back | `chat-hygiene expand --zip PATH` |
| Stop being nudged about an id | `chat-hygiene dismiss REF` |
| Clear a dismissal | `chat-hygiene undismiss REF` |
| List ids for scripts | `chat-hygiene select --top 5` |

Threshold (OR): **folder ≥ 2 MiB** or **main jsonl ≥ 1 MiB**.

---

## Naming

Prefer these verbs:

| Prefer | Also | Means |
|---|---|---|
| `compress` | `zip`, `z`, `chz` | Archive chat → zip, leave tiny stub |
| `expand` | `unzip`, `restore` | Restore chat to **original path** |
| `snip` | `x`, `sample` | Sample head/tail turns (not unzip) |
| `preview` | `p`, `dry-run` | Show from→to + snip; change nothing |
| `report` | `r`, `chr` | Ranked size table |
| `check` | `c`, `chc` | Undismissed offenders |
| `dismiss` | `d` | Never nudge this id again |
| `undismiss` | `ud` | Clear dismissal |
| `select` | `s` | Print selected ids |
| `help` | `h` | This guide |

Old aliases still work: `compact`→compress, `extract`→snip.

---

## report

Rank chats for the current project (or `--all`).

```text
chat-hygiene report
chat-hygiene r
chr
chat-hygiene report --all
chat-hygiene report --all-rows
```

Table columns: Rank | **Title** (bold markdown link) | Folder | Jsonl | ~Tokens | Msgs | Ref  
Footer: Top 10 total + overall total.  
`⚠` marks chats over threshold.  
Ref is a short id like `b4efd1ad…` (first 8 chars), linked to the raw transcript file.

**Title link by tool**

| Tool | Title opens | Ref opens |
|---|---|---|
| Cursor | raw `.jsonl` (`file://`) — no chat-UI deeplink yet | raw `.jsonl` |
| Claude Code | `claude://code/{session-id}` (chat UI) | raw `.jsonl` |
| Codex | `codex://threads/{thread-id}` (chat UI) | raw `.jsonl` |

---

## check

List undismissed chats over threshold. Exit `1` if any, `0` if clean.

```text
chat-hygiene check
chc
chat-hygiene check --all
```

---

## preview

Dry-run. Shows **from (original path) → to (zip)** plus a snip of turns.  
Does **not** zip, move, delete, or write stubs.

```text
chat-hygiene preview --top 3
chat-hygiene p --rank 1-5
chp b4efd1ad
```

---

## snip

Sample head/tail turns so you (or an agent) can write an ultra-squeeze summary.  
This is **not** unzip — use `expand` for that.

```text
chat-hygiene snip --rank 1
chat-hygiene x --top 3
```

---

## compress

Archive chat(s): zip original → `~/Documents/chat-archives/…`, write summary,
leave a tiny stub in tool storage.

`--summary` / `--summary-dir` are **INPUT** paths (markdown you already wrote).  
They are **not** a dry-run. Use `preview` to inspect first.

```text
# single
chat-hygiene compress b4efd1ad --summary /tmp/b4ef.md
chat-hygiene zip b4efd1ad --summary /tmp/b4ef.md
chz b4efd1ad --summary /tmp/b4ef.md

# batch by rank / top N  (one <full-chat-id>.md per chat in the dir)
chat-hygiene compress --top 3 --summary-dir ~/tmp/ch-summaries
chat-hygiene compress --rank 1-5 --summary-dir ~/tmp/ch-summaries
```

Every compress writes restore metadata:

1. Inside the zip: `CHAT_HYGIENE_MANIFEST.json`
2. Sidecar: `….manifest.json` next to the zip
3. Summary + stub text: original path, zip path, expand command

---

## expand

Put a chat back at its **original path** using the manifest inside/beside the zip.

```text
chat-hygiene expand --zip ~/Documents/chat-archives/cursor/…/id-YYYYMMDD.zip
chat-hygiene unzip --zip ~/Documents/chat-archives/…/id-YYYYMMDD.zip
```

Optional: pass a chat id/ref to verify it matches the zip.

---

## dismiss / undismiss

```text
chat-hygiene dismiss b4efd1ad
chat-hygiene d --rank 1-3
chat-hygiene undismiss b4efd1ad
chat-hygiene ud --top 1
```

Dismissed ids are skipped by `check` / nudges forever (until undismiss).

---

## select

Print selected chats as `rank<TAB>full_id<TAB>ref<TAB>title` (scripts/pipelines).

```text
chat-hygiene select --top 5
chat-hygiene s --rank 2-4
```

---

## Selection flags (shared)

Most mutating/read commands accept:

| Flag | Meaning |
|---|---|
| `REF…` | One or more full ids or short prefixes (`b4efd1ad`) |
| `--top N` | Largest N by folder size |
| `--rank A-B` | Ranks from report, e.g. `1-5` or `3` |
| `--all` | Search all discovered projects |
| `--path DIR` | Project path (default: cwd) |

---

## examples

### Everyday

```text
chat-hygiene help
chat-hygiene report
chat-hygiene check
```

### Inspect before changing anything

```text
chat-hygiene preview --top 3
chat-hygiene snip --rank 1
```

### Compress one chat

```text
# 1) sample turns, write a short .md yourself or via agent
chat-hygiene snip b4efd1ad > /tmp/notes.txt
# 2) save ultra-squeeze as /tmp/b4ef.md  (title, goal, decisions, follow-ups)
# 3) compress
chat-hygiene compress b4efd1ad --summary /tmp/b4ef.md
```

### Compress top 3 (batch)

```text
mkdir -p ~/tmp/ch-summaries
chat-hygiene select --top 3
# write ~/tmp/ch-summaries/<full-chat-id>.md for each
chat-hygiene compress --top 3 --summary-dir ~/tmp/ch-summaries
```

### Undo

```text
chat-hygiene expand --zip ~/Documents/chat-archives/cursor/PROJECT/id-YYYYMMDD.zip
# open the sidecar to see from→to without expanding:
#   …/id-YYYYMMDD.manifest.json
```

### Stop nudges

```text
chat-hygiene dismiss --rank 1-3
```

---

## Paths

All locations are **home-relative / XDG-style**. Nothing is hard-coded to a username or project.

| What | Where |
|---|---|
| CLI | `~/.local/bin/chat-hygiene` |
| Config | `~/.config/chat-hygiene/config.toml` |
| Dismissals | `~/.config/chat-hygiene/state.json` |
| Zip backups | `~/Documents/chat-archives/<tool>/<project>/` |
| Manifests | next to each zip (`*.manifest.json`) + inside zip |
| Summaries | `~/.local/share/chat-hygiene/summaries/<tool>/<project>/` |
| This help | `chat-hygiene help`  or  `~/.local/share/chat-hygiene/HELP.md` |
| Cursor chats | `~/.cursor/projects/<slug>/agent-transcripts/` |
| Claude chats | `~/.claude/projects/` (when present) |
| Codex chats | `~/.codex/sessions/` (when present) |

`<project>` / `<slug>` are derived at runtime from the current working directory (or discovered tool layout). Absolute paths appear only inside **runtime manifests** (so `expand` can restore that machine’s original folder).

---

## Agents (Cursor / Claude / Codex)

- Cursor skill: `~/.cursor/skills/chat-hygiene/SKILL.md`
- Never compress/expand/dismiss without an explicit user yes
- Prefer `preview` before `compress`
- After yes: snip → write summary → `compress … --summary` / `--summary-dir`
