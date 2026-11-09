# chat-hygiene

Report and **compress** / **expand** oversized coding-agent chats (Cursor, Claude Code, Codex).

Python 3 stdlib only. No pip packages. Installs into your home folder (no admin).

## Install

Requires **Python 3**.

```sh
git clone https://github.com/dineybomfim/chat-hygiene.git
cd chat-hygiene
sh install.sh
```

That copies the tool into `~/.local/share/chat-hygiene`, puts `chat-hygiene` on `~/.local/bin`, and links the Cursor skill.

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
