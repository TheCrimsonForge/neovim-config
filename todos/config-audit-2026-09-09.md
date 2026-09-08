# Whole-config audit, 2026-09-09

## SCOPE — read this before trusting the verdict

This was a **targeted pattern sweep, not a deep review and not a code review.**

Method: grep the whole repo for a fixed list of failure classes (hot-path autocmd
events, blocking calls, timers, `feedkeys` with remap, `exec_autocmds`, dead
requires), measure startup, then read only the files those greps pointed at.

- **Coverage: ~800 of 12,600 lines, about 5%.** Complete for the patterns
  searched, near-zero for everything else.
- **Never opened:** `keymaps.lua` (858 lines), `codecompanion.lua` (846),
  `snacks.lua` (824), `oil.lua` (734) — the four biggest live files.
- **No correctness review was done.** No logic bugs, API misuse, dead branches,
  error handling or edge cases were looked at.

So "nothing critical" below means *no instance of the classes searched for*. It
does not mean the config was read and found sound. A real review is still owed.

---

Sweep run after a run of theme changes. **Nothing critical was found within the
scope above. Nothing was fixed.** This file is the record so the items can be
picked up later.

## Verdict

| area | result |
| --- | --- |
| Startup | ~50 ms headless, 5 runs. No action. |
| Per-keystroke hot paths | Clean. See below. |
| Recursion | No unguarded loop found. |
| Blocking I/O | Only on explicit keypress. |
| Dead code | 2 parked modules, correctly documented. |

Measured, not assumed: startup was timed 5x with `--startuptime`; the slowest
single entry is `require('config.lazy')` at 23.7 ms, which is lazy.nvim itself.

## What was checked and found clean

**Only one `<MouseMove>` handler exists** (`lua/config/mouse-hover.lua:325`), the
hottest possible path. It is correctly ordered: an O(1) cell-position dedup
returns first, and only then a 16 ms (~60 Hz) throttle. The comment claiming
"~99% short-circuit" matches the code.

**Only one `CursorMoved`/`CursorMovedI` pair exists**
(`lua/plugins/codecompanion.lua:675`), and it is created on
`CodeCompanionInlineStarted` and destroyed on `...Finished`, with a defensive
`stop_tracking()` on start to clear a leak from a prior op.

**Two `CursorHold` autocmds** (`lua/config/options.lua:212,220`). `CursorHold`
fires once per idle period, not repeatedly, so `checktime` and the message-clear
timer are both bounded.

**`vim-visual-multi.lua:49` fires a synthetic `InsertEnter`** — the one place in
the config that raises an event it also listens near. It is guarded by a
`refreshing` re-entrancy flag, so it cannot loop.

**LSP** runs `debounce_text_changes = 200` globally via `vim.lsp.config("*")`.
**blink.cmp** sources are the four defaults, no scanners added.
**No `WinScrolled`, `TextChanged`, or `InsertCharPre` handler exists** outside
disabled plugins.

## Keep in mind — not bugs, watch these

1. **`codecompanion` cursor tracker can leak between operations.**
   `lua/plugins/codecompanion.lua:675`. If `CodeCompanionInlineFinished` never
   fires (aborted or failed request), the `CursorMoved`/`CursorMovedI` autocmd
   survives until the next inline op calls `stop_tracking()`. The callback is
   ~3 API calls so the cost is tiny, but it is an unbounded-lifetime autocmd on a
   per-keystroke event. A `CodeCompanionInlineError` teardown, or a timeout,
   would close it.

2. **`folding.lua` retries by polling.** Lines 154 and 190 use
   `vim.defer_fn(..., 150)` with a retry counter to wait for UFO to compute a
   fold. Bounded at 5 tries (750 ms) and size-gated at 100 KB, so it is safe, but
   it is a poll, not an event. If UFO ever exposes a "folds ready" event, prefer it.

3. **`git blame`/`git show` block the UI.**
   `lua/config/keymaps.lua:561,626,641` call `vim.fn.system` synchronously. This
   is allowed — they run on an explicit keypress — but on a large repo or a slow
   filesystem the editor will freeze for the duration. `vim.system()` with a
   callback is the async replacement if it ever bites.

4. **`neovide.lua` now feeds keys with remap enabled.** Line 60 uses
   `nvim_feedkeys(..., "m", ...)` to forward `<D-k>` to `<M-k>`. Safe today
   because `<M-k>` maps to a Lua function. It would become an infinite loop if
   anything ever mapped `<M-k>` back to `<D-k>`.

5. **Two dead modules on disk.** `lua/config/smooth-scroll.lua` and
   `lua/config/_unstable_tabline.lua` are required by nothing. Both are
   deliberately parked with a documented reason, so this is a note, not a
   cleanup request. Do not "discover" them as bugs.

6. **`options.lua:220` clears the message line after 2 s idle.** Intentional, but
   it means a plugin message can vanish before it is read. If messages ever seem
   to disappear mysteriously, this is why.

## README is out of date

`README.md` was last touched 2026-09-08 and predates the palette retune and the
Copilot change. Confirmed stale:

- **Theme table (line ~257) is wrong on 4 of 8 rows.** It lists type `#7dcfff`
  (live `#2ac3de`), function `#1d98cd` (live `#359ee9`), names `#aea134` (live
  `#baac0d`), comment `#576d74` (live `#5f767d`). Only punctuation `#7f9195`,
  body, string and keyword still match.
- Says the palette is **"closed as of 2026-09-06"** and "no further tweaking is
  planned or needed". It was retuned twice since.
- Says LSP **`debounce_text_changes = 300ms`**; the code says `200`.
- Says **`<C-k>`** toggles Copilot; that moved to `<M-k>` to reclaim the native
  insert-mode digraph key.
- Describes **copilot.lua as active** (lines 47, 63, 167) and line 326 lists a
  Copilot subscription as a requirement. The plugin is `enabled = false`.
- Performance section lists **flash** as disabled, which is correct
  (`flash.lua` is `enabled = false`) — no change needed there.

## Related

- Live palette values: `CLAUDE.md`, the only reconciled snapshot.
- The three palette archives carry historical banners as of 2026-09-09.
- Silent-failure surfaces: [`../notes/silent-failure-surfaces.md`](../notes/silent-failure-surfaces.md).
