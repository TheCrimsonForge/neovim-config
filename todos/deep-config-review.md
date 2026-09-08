# Deep config review — QUEUED, not started

**Status: not started. Queued 2026-09-09, to run 2026-09-10 or later.**
**Estimated: 4 sessions.** Do not try to do it in one.

This is the real review that [`config-audit-2026-09-09.md`](config-audit-2026-09-09.md)
is **not**. That one was a grep-driven pattern sweep over ~800 of 12,613 lines
(about 5%), blind to anything its patterns did not name, and it did no
correctness review at all. Read its SCOPE section first, then treat its verdict
as covering only the classes it lists.

---

## 1. Objective and non-objective

**Objective.** Read the live config end to end and find defects the pattern sweep
structurally could not: logic bugs, API misuse, dead branches, broken failure
paths, lifecycle leaks, and decisions duplicated across files that can drift apart.

**Non-objective.** This is not a redesign, not a refactor, and not a tidy-up.
Do not propose changes because something reads oddly. The config is full of
deliberate, measured decisions that look wrong without their history — several
are documented precisely because a previous session "fixed" them by mistake.

**Output is findings, not commits.** Fix nothing during the read. Fixes are a
separate, agreed pass at the end.

---

## 2. Read these before touching anything

In this order. Skipping them is how a reviewer produces confident wrong findings.

1. `CLAUDE.md` (repo root) — the entry point, the live palette table, the two
   structural traps, the file-browser history.
2. `rules.md` — discipline rules and the active config-freeze window.
3. `neovim-config-change-gate.md` — decides whether a proposed change should
   happen at all. **Apply it to every finding before writing it down.**
4. `docs/CLAUDE.md` — the canonical doc, including the Performance Rules.
5. [`../notes/silent-failure-surfaces.md`](../notes/silent-failure-surfaces.md) —
   fifteen places that accept a wrong value and do nothing. Also
   `rg "WARN: SILENT" lua/`.
6. [`config-audit-2026-09-09.md`](config-audit-2026-09-09.md) — what is already
   known, so you do not re-derive it.

---

## 3. Rules of engagement

**Read whole files, in order, top to bottom.** Do not grep-and-skim. Skimming is
exactly what produced the shallow pass, and these files are dense with comments
that change the meaning of the code below them.

**A comment is a claim, not evidence.** This config's comments are unusually
detailed and mostly accurate, but several were found contradicting the code on
2026-09-09. When a comment asserts a number or a behaviour, verify it or mark the
finding as unverified.

**A clean test proves nothing unless it can detect the broken state.** Before
believing any check, run it once against a deliberately broken version. If it
cannot tell the two apart, it is worthless. This has already produced false
"working" results in this repo.

**Headless nvim never loads `config/keymaps.lua`** — it is gated on
`VeryLazy`/`UIEnter` — so keymap probes falsely report NOT MAPPED. Always run a
control before believing a negative.

**Do not review dead code line by line.** Confirm the gate still holds, then move
on. See the skip list in phase 5.

---

## 4. Phases

### Phase 0 — Baseline (30 min, do once)

Capture what "unchanged" means so any later fix can be proven safe.

- [ ] Snapshot all highlight groups. The method from 2026-09-09:
      dump `nvim_get_hl` for every name in `getcompletion("", "highlight")`,
      sorted, to a file. **Filter out `lualine_[abcxyz]_<n>_*`** — those numbers
      are allocation counters that shift without any colour changing, and they
      will produce a false diff.
- [ ] Snapshot startup: `--startuptime`, 5 runs. Current baseline is **~50 ms**,
      slowest entry `require('config.lazy')` at 23.7 ms.
- [ ] Snapshot the keymap table for `n`, `i`, `v`, `t` from a **non-headless**
      instance, or accept that keymaps.lua findings cannot be probed headlessly.
- [ ] Confirm a clean boot: `XDG_STATE_HOME=/tmp/nvs XDG_CACHE_HOME=/tmp/nvc nvim --headless '+qa'`.

### Phase 1 — `lua/config/keymaps.lua`, 858 lines (1 session)

The most-touched surface in the config, and the one most likely to hold a real
defect. Known structure worth reviewing as units:

| lines | area | what to question |
| --- | --- | --- |
| 24–148 | float styling helpers (`sync_float_nontext_hl`, `hide_float_marker`, `style_doc_float`, `float_content_wraps`, `space_after_code_fences`) | width/wrap arithmetic, off-by-one on borders, behaviour on a zero-width or huge window |
| 213–354 | `hover_opts` and the `<Esc>` handler | the `vim.schedule` E565 workaround — is every mutation actually inside the schedule? |
| 355–407 | `scroll_popup_or`, `is_editor_window`, `editor_scroll_or_arrow` | which window wins when several floats are open; the documented "scrolled oil instead of the picker" class of bug |
| 412–452 | the `<Tab>` handler | four fall-through branches; confirm each is reachable and ordered correctly, and that the `1<C-i>` count prefix comment still holds |
| 462–700 | terminal toggle, git blame/show | three blocking `vim.fn.system` calls; check argument quoting and what happens on a non-git buffer or a detached HEAD |
| 700–858 | `show_unsaved_files`, `qf_add`, quickfix wiring | buffer-local map lifetime, and whether the float can leak |

Cross-check every `<leader>` binding against `docs/` and `README.md`; note any
that no longer exist or now point at a disabled plugin. **`<D-k>` was one of
these** and was only caught by accident.

### Phase 2 — `lua/plugins/codecompanion.lua`, 846 lines (1 session)

The most dynamic file: it creates and destroys autocmds at runtime and patches
plugin internals. Everything is `pcall`-wrapped, which is the risk — a real
failure is indistinguishable from an intentional no-op.

- [ ] `opts` block (17–198): adapter config, the Copilot adapter in particular.
      **Copilot is now `enabled = false` and the subscription is inactive**, so
      confirm what this file does when the adapter cannot authenticate.
- [ ] `config` (198+): every `pcall` — for each one, ask what a silent failure
      would look like to the user, and whether it would ever be noticed.
- [ ] Highlight overrides (~319–330): re-defined on `ColorScheme`. Verify they do
      not fight the colorscheme's own `on_highlights`.
- [ ] Cursor tracker (~660–700): already known to leak if
      `CodeCompanionInlineFinished` never fires. Confirm there is no error event
      to hook, and check whether `stop_tracking` is reachable from every path.
- [ ] `keys` (763+): lazy-load triggers; confirm none force an eager load.

### Phase 3 — `lua/plugins/snacks.lua` (824) and `lua/plugins/oil.lua` (734) (1 session)

These two interact — oil is a popup, snacks pickers open over it — and the
documented bugs live in that overlap.

**snacks.lua**

- [ ] Disabled sub-modules (189–194): `scroll`, `animate`, `words`, `indent`,
      `scope`, `dim`. Confirm each is genuinely off; the comments say why each
      one is a hot-path cost.
- [ ] `picker_scroll` / `explorer_window_keys` (61–182): the count handling and
      the two-window problem — keys bound on the list are unreachable from the
      input. For every key, ask which window has focus when it is pressed.
- [ ] `backdrop = false` in two places: these **must stay**. Confirm both are
      still present. This is the snacks transparency mis-detection, not a
      preference.
- [ ] `layout` (647+): check nothing spells out a `box` in a way that drops the
      preset's overrides — a documented silent failure.

**oil.lua**

- [ ] Backdrop lifecycle (64–133): `create_backdrop`/`close_backdrop` and the
      "never stack two" guard. Trace the interrupted-close path.
- [ ] `hide_bg_search_highlights` (102) and `saved_winhl` restore — does state
      survive an abnormal close?
- [ ] Path label (248–443): `clean_path`, `path_segments`, `segments_width`,
      `fit_segments`, `set_oil_winbar`. Width arithmetic on a narrow window and
      on a very deep path.
- [ ] The `VimEnter` buffer swap for `nvim <dir>`.
- [ ] Confirm nothing per-directory has crept into `float.win_options` — oil
      re-applies that whole table on every navigation.

### Phase 4 — Second tier and synthesis (1 session)

- [ ] `lua/config/sql-keyword-source.lua` (476) — a custom completion source, so
      it is on the completion hot path. Highest remaining perf risk.
- [ ] `lua/config/ai-prompts.lua` (447)
- [ ] `lua/plugins/lsp.lua` (318) — untouched since before the freeze and
      described as production-validated; verify that is still true.
- [ ] `lua/plugins/blink-cmp.lua`, `lua/plugins/performance.lua`
- [ ] `lua/config/mouse-hover.lua` (551) — the `on_mouse_move` handler was read
      and is sound; the other ~480 lines were not.
- [ ] `lua/config/autocmds.lua`, `options.lua`, `quickfix-*.lua`, `ui.lua`
- [ ] Cross-file synthesis: the same decision expressed twice and able to drift.
      Known instance to start from — the palette lives in `variants.lua` but is
      described in `CLAUDE.md`, three archive docs and `README.md`.

### Phase 5 — Skip list, confirm the gate then move on

| file | lines | gate |
| --- | --- | --- |
| `snacks-file-browser.lua` | 913 | `ENABLED = false`, and sets **no** `enabled` key — verify that is still true, it is a fragment-collision trap |
| `telescope-file-browser.lua` | 738 | `ENABLED = false` |
| `_unstable_tabline.lua` | 424 | required by nothing |
| `smooth-scroll.lua` | 105 | required by nothing |
| `*.bak` | — | not loaded |
| `avante`, `sidekick`, `bufferline`, `spectre`, `harpoon`, `flash`, `copilot` | — | `enabled = false` |

Total skipped: roughly 2,200 lines, so the real read is about **10,400 lines**.

---

## 5. Traps that will produce wrong findings

- **lazy.nvim fragment collisions.** Only the LAST fragment's
  `init`/`config`/`enabled` per plugin survives, ordered by module name. Grep for
  a second spec file before concluding anything about those keys. This silently
  killed `snacks.lua`'s entire `init` for weeks.
- **`enabled = false` in one fragment disables the whole plugin.** That is why
  `snacks-file-browser.lua` gates on a local flag and sets no `enabled` key. An
  `init` that merely returns early still wins the lookup — the key must be absent.
- **`transparent` must be an explicit `false`.** Commenting the line out
  re-enables transparency, which then makes the oil backdrop a solid black sheet.
- **`bg_popup` must stay unset** in `on_colors`; the completion menu depends on
  base04. `bg_statusline` is the lualine key, not the native `StatusLine` key —
  this was mis-documented until 2026-09-09.
- **A duplicate key in a Lua table is not an error.** The last one wins and the
  earlier lines become lies that a reorder would activate. Four duplicate
  `boolean` keys were found this way.
- **Unresolved picker action names get typed as keystrokes** rather than erroring,
  and an action name matching a snacks built-in replaces it everywhere.
- **`virt_lines_above` on line 1 renders nothing** while still being counted.

---

## 6. Recording findings

One line per finding, ranked by severity at the end:

```
<file>:<line> — <what is wrong> → <when it breaks, concretely> → <cheapest fix>
[verified | unverified] [change-gate: pass | fail | n/a]
```

- **Flag anything genuinely dangerous immediately** — data loss, a hang, a
  recursion — rather than saving it for the write-up.
- Mark every finding verified or unverified. Do not blur the two.
- Run the change gate before writing a finding down. A defect that the gate says
  should not be fixed is still worth recording, but say so.

Write results to `todos/deep-config-review-findings.md`, and update this file's
status line as each phase completes.

---

## 7. Carry-over

Already recorded, confirm and fold in rather than re-deriving:

- Six watch-items in [`config-audit-2026-09-09.md`](config-audit-2026-09-09.md).
- `README.md` is stale in six specific ways (four dead theme hexes, palette
  described as closed, LSP debounce `300` vs the real `200`, `<C-k>` vs `<M-k>`,
  Copilot presented as active, Copilot subscription listed as a requirement).
- The three palette archives now carry historical banners; `CLAUDE.md`'s table is
  the only reconciled snapshot.
- `lua/config/neovide.lua` has an uncommitted `<D-k>` fix.
