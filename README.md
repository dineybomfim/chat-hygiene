<p align="center">
  <img src="logo-200.png" alt="chat-hygiene" width="120" height="120" />
</p>

<h1 align="center">chat-hygiene</h1>

<p align="center">
  <strong>Stop paying tokens for chats you already finished.</strong>
</p>

Coding agents (Cursor, Claude Code, Codex) keep every turn on disk. A long thread becomes a multi‑megabyte transcript: slower IDE/indexing, more disk, and—worst—huge @‑attachments and agent re‑reads that burn **context window** and **API tokens** on noise you no longer need. Past decisions get buried in the raw log instead of a short, reusable summary.

**chat-hygiene** ranks oversized chats, helps you **summarize** what mattered, then **compresses** the original to a zip + ultra‑summary (with a restore manifest) and leaves a tiny stub so tools and agents stop re‑ingesting the full history. Same outcome: less context, lower usage, cheaper follow‑ups, and decisions you can still find—without deleting the archive.

<p align="center">
  <img src="https://img.shields.io/badge/python-3%20stdlib-3776AB?style=flat&logo=python&logoColor=white" alt="Python 3 stdlib" />
  <img src="https://img.shields.io/badge/deps-none-brightgreen?style=flat" alt="No dependencies" />
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey?style=flat" alt="macOS and Linux" />
  <img src="https://img.shields.io/badge/agents-Cursor%20%7C%20Claude%20%7C%20Codex-8A2BE2?style=flat" alt="Cursor Claude Codex" />
  <img src="https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25?style=flat&logo=gnubash&logoColor=white" alt="bash and zsh" />
  <a href="https://github.com/dineybomfim/chat-hygiene/stargazers">
    <img src="https://img.shields.io/github/stars/dineybomfim/chat-hygiene?style=flat" alt="Stars" />
  </a>
</p>

Python 3 stdlib only. No pip packages. Installs into your home folder (no admin).

## Install

Requires **Python 3**. Same `install.sh` works from a clone or straight from GitHub.

### One-liner (fetch → install → cleanup)

```sh
curl -fsSL https://raw.githubusercontent.com/dineybomfim/chat-hygiene/main/install.sh | sh
```

That downloads the repo to a temp folder, installs into your home, then deletes the temp folder. Nothing is left except the runtime under `~/.local/…`.

### From a local clone

```sh
git clone https://github.com/dineybomfim/chat-hygiene.git
cd chat-hygiene
sh install.sh
```

Both paths copy the tool into `~/.local/share/chat-hygiene`, put `chat-hygiene` on `~/.local/bin`, and link the Cursor skill.

Then open a **new** terminal and run:

```sh
chat-hygiene help
```

If the command is not found, add this to `~/.zprofile` or `~/.bashrc` and reopen the terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Update

```sh
curl -fsSL https://raw.githubusercontent.com/dineybomfim/chat-hygiene/main/install.sh | sh
```

Or from a clone you keep around:

```sh
cd chat-hygiene
git pull
sh install.sh
```

Your config, dismissals, zip archives, and summaries are kept.

### Uninstall (optional)

```sh
rm -f ~/.local/bin/chat-hygiene ~/.local/bin/chr ~/.local/bin/chc ~/.local/bin/chp ~/.local/bin/chz
rm -rf ~/.local/share/chat-hygiene ~/.cursor/skills/chat-hygiene
```

Config (`~/.config/chat-hygiene/`) and archives (`~/Documents/chat-archives/`) are left alone.

## Shortcuts

| Alias | Command |
|---|---|
| `chr` | `chat-hygiene report` |
| `chc` | `chat-hygiene check` |
| `chp` | `chat-hygiene preview` |
| `chz` | `chat-hygiene compress` |

Tab completion:

```sh
# zsh
source ~/.local/share/chat-hygiene/completions/chat-hygiene.zsh
# bash
source ~/.local/share/chat-hygiene/completions/chat-hygiene.bash
```

## Help

```sh
chat-hygiene                 # full guide
chat-hygiene help            # same
chat-hygiene help compress   # one topic
chat-hygiene help examples   # copy-paste recipes
```

## Commands

| Command | Also | Purpose |
|---|---|---|
| `help` | `h`, `doc` | Full guide with examples |
| `report` | `r` | Rank chats; title + ref links |
| `check` | `c` | Undismissed offenders |
| `preview` | `p`, `dry-run` | Dry-run: **from→to** paths + snip; no changes |
| `snip` | `x`, `sample` | Sample head/tail turns to write a summary |
| `compress` | `zip`, `z` | Zip chat → archive, store summary, leave stub |
| `expand` | `unzip`, `restore` | Put chat back at **original path** |
| `dismiss` | `d` | Stop nudges |
| `undismiss` | `ud` | Clear dismissal |
| `select` | `s` | Print selected ids |

### `--summary` is an INPUT

Pass the ultra-squeeze `.md` you already wrote into `compress`. For a look-only pass, use `preview`.

```sh
chat-hygiene preview --top 3
chat-hygiene compress --rank 1-3 --summary-dir ~/tmp/ch-summaries
chat-hygiene expand --zip ~/Documents/chat-archives/.../id-YYYYMMDD.zip
```

## Backup manifest (from → to)

Every `compress` records restore metadata in three places:

1. **Inside the zip:** `CHAT_HYGIENE_MANIFEST.json`
2. **Sidecar:** same path as the zip with `.manifest.json`
3. **Summary + stub text:** original path, zip path, expand command

`expand --zip …` restores to that exact original path.

## Config

`~/.config/chat-hygiene/config.toml`

| What | Where |
|---|---|
| CLI | `~/.local/bin/chat-hygiene` |
| Runtime files | `~/.local/share/chat-hygiene/` |
| Config / dismissals | `~/.config/chat-hygiene/` |
| Zip backups | `~/Documents/chat-archives/` |
| Summaries | `~/.local/share/chat-hygiene/summaries/` |

Threshold (OR): folder ≥ 2 MiB or main jsonl ≥ 1 MiB.

## Agent adapters

- Cursor skill (installed automatically): `~/.cursor/skills/chat-hygiene/SKILL.md`
- Claude: see `adapters/claude.md`
- Codex: see `adapters/codex.md`
