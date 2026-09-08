-- The solarized-osaka builds, one `:colorscheme` away from each other.
--
--   solarized-osaka-custom-latest  the selection we run  <- default
--   solarized-osaka-custom-v1      the copper build custom-latest replaced
--   solarized-osaka-custom-v2      custom-v1 on the warm keyword (yellow)
--   solarized-osaka-custom-v3      custom-v1 on the softer terracotta punctuation
--   solarized-osaka-original       upstream craftzdog, nothing of ours applied
--
-- `custom-latest` IS A MOVING NAME -- always "whatever we run today" -- and the
-- numbered ones are frozen snapshots. WHEN custom-latest IS SUPERSEDED: number
-- its current values first, THEN move the new ones into the palette. Never edit
-- a numbered build.
--
-- Costs nothing at startup: nothing here is read until `:colorscheme` names a
-- build, because the only entry points are the one-line files in `colors/`.
--
-- How a build works, why `original` is a precise reference, how to add one, and
-- the `vim.g.colors_name` trap: notes/palette-reference.md, section "Builds".

local palette = require("colorschemes.solarized-osaka.palette")

---@class SolarizedOsakaBuild
---@field palette table<string, string>|nil role overrides, keys from the palette's return block
---@field config table|nil plugin option overrides

---Values come from `palette.variants`, so a hex is never copied.
---@type table<string, SolarizedOsakaBuild>
local builds = {
  -- `on_highlights` carries everything this repo decided about syntax colour, so
  -- switching it off is the whole difference. Deliberately NOT a full
  -- `config.setup({})`, which would also discard non-syntax plugin-spec options
  -- and make any difference you see ambiguous.
  original = { config = { on_highlights = function() end } },

  -- The daily selection. Only the roles that differ from the base palette.
  ["custom-latest"] = {
    palette = {
      type = palette.variants.type.nvim_type,
      -- Both on the MAXIMIN grey rung 2026-09-09, off `kanagawa_mid` (#96abd3).
      -- The periwinkle was a fourth hue in the blue band and the least meaningful
      -- ink at the third-highest contrast (8.21:1, above strings and keywords).
      -- Measured over Go/bash/devops/js-ts/jsx-tsx/python: worst chromatic pair
      -- 14.2 -> 16.5, tightest colour-blind pair 2.3 -> 4.8, p10 unchanged at
      -- 16.5. init.lua keeps ecma brackets on base0 -- see the note there.
      delimiter = palette.variants.delimiter.mid_high,
      bracket = palette.variants.delimiter.mid_high,
      func = palette.variants.func.vivid,
      -- One value for every language, Go included: the Go-specific override was
      -- dropped when `tokyonight_muted` landed. `tokyonight_dim` chosen by eye
      -- 2026-09-08: TN's hue at our L*68, and the strongest separation from the
      -- accent yellow of any candidate (dE 29.5). It carries C*54.8, above the
      -- C*40 this role's dose note asks for, and CVD is its weak axis (5.4
      -- deutan) -- accepted knowingly; `tokyonight_muted` is the safer swap.
      boolean = palette.variants.boolean.tokyonight_dim,
      boolean = palette.variants.boolean.orange_vivid,
      boolean = palette.variants.boolean.orange_bright,
      boolean = palette.variants.boolean.tokyonight_dim,
      -- boolean = palette.variants.boolean.tokyonight_muted,
      -- Tokyo Night's boolean orange, adapted to our lightness. `tokyonight` is
      -- TN's exact #ff9e64, `amber` trades hue fidelity for max separation.
      -- member = palette.variants.member.rose_soft,
      -- member = palette.variants.punctuation.explored.salmon,

      -- GO ONLY: init.lua paints this on `@variable.member.go` alone. Go reads
      -- `x.Field` on nearly every line, with a one-letter receiver, so the field
      -- is what you actually read. The same capture in TS/JS also covers object
      -- members, where it flooded files with warm ink, so every other language
      -- keeps the theme's own value (String's cyan500).
      --
      -- Salmon over coral 2026-09-08, by eye. Same hue (39.8 vs 40.0) and 2.0 L*
      -- higher, 5.62:1. Nearest warm neighbour either way is
      -- `boolean.orange_bright` (#e39a71): salmon dE 12.6 (9.2 deutan), coral
      -- 14.0 (10.9). Both clear; if numbers and struct fields ever blur on one
      -- line, that pair is why and coral is the one-word fix.
      -- UNUSED since 2026-09-08: Go fields moved to the accent yellow, which
      -- init.lua paints directly. Set this to `punctuation.explored.salmon` (or
      -- `.coral`) and switch the Go field block back to `palette.member` to
      -- restore a dedicated field colour. `false`, never nil.
      member = false,
      --  NOTE: both coral and salmon are valid however coral is a little bit better at color separation
      --  so i decided to go with coral, both colors are good but i just choose the one better color separation to my eyes.
      -- member = palette.variants.punctuation.explored.coral,
      --
      -- REVERTED 2026-09-08: back to the theme's own value, which is String's
      -- cyan500. One fewer warm colour, on the grounds that the palette was
      -- carrying too many at once. `false`, not nil, so the override registers.
      -- member = false,

      parameter = palette.variants.keyword.brighter,
      punctuation = palette.variants.keyword.brighter,
      -- parameter = palette.variants.punctuation.explored.salmon,
      -- punctuation = palette.variants.punctuation.explored.salmon,
      -- NOTE: punctuation + parameter, final call 2026-09-08. Terracotta red and
      -- subdued yellow stayed close; analysis scored yellow better and it still
      -- reads best in daily use, so yellow stays even though it goes against my
      -- personal colour preference. No red variant found that beats it.
      --
      -- Verdict: the palette is ~90% done. The last 10% still open -- a red that
      -- can replace the subdued yellow, object member colours, object/dict key
      -- and value colours, boolean colours. Not worth more searching; only reopen
      -- if one of these clearly bothers me in daily use.
      --
      -- punctuation = palette.variants.punctuation.terracotta,
      -- parameter = palette.variants.punctuation.terracotta,
      -- punctuation = palette.variants.punctuation.explored.copper,
      -- parameter = palette.variants.punctuation.explored.copper,
      -- punctuation = palette.variants.punctuation.explored.clay,
      -- parameter = palette.variants.punctuation.explored.clay,
      -- comment = palette.variants.comment.subtle,
      -- Dropped TWO stops from `readable` 2026-09-09: at 4.56:1 comments read as
      -- too bright, and `subtle` (dE 2.8) was still not enough. `dimmer` is 4.1 L*
      -- below `readable` on the same hue and chroma, dE 4.0, and sits between
      -- `subtle` and upstream. It gives up AA (3.96:1) to do it, knowingly -- the
      -- upstream value this config ran for months is lower still at 3.48:1.
      -- Ladder in palette.lua; `false` here means upstream #576d74.
      comment = palette.variants.comment.dimmer,
    },
  },

  -- Ran 2026-08-11 to 2026-09-05. The fallback that needs no argument: a full
  -- month of proven daily use.
  --
  -- WARN: SILENT FAILURE. The `false`s are meaningful, not padding -- they mean
  -- "follow the theme's own base0" for body and delimiters, and "follow
  -- `punctuation`" for brackets. They must be `false`, NEVER `nil`: `nil` is an
  -- absent key, so `M.load`'s `pairs` never sees it and the override silently
  -- does not happen. Same for every build below.
  ["custom-v1"] = {
    palette = {
      punctuation = palette.variants.punctuation.copper_mid,
      parameter = palette.variants.punctuation.copper_mid,
      bracket = false,
      body = false,
      delimiter = false,
    },
  },

  -- The warm keyword, kept switchable after violet won on 2026-08-10. Reach for
  -- it if violet ever reads as too recessive. Built on custom-v1 deliberately:
  -- custom-latest already spends this yellow on the warm side.
  ["custom-v2"] = {
    palette = {
      keyword = palette.variants.keyword.balanced,
      punctuation = palette.variants.punctuation.copper_mid,
      parameter = palette.variants.punctuation.copper_mid,
      bracket = false,
      body = false,
      delimiter = false,
    },
  },

  -- The punctuation colour from before 2026-08-11, on the custom-v1 base. The one
  -- value that satisfies the keyword/punctuation chroma pairing perfectly.
  --
  -- WARN: SILENT FAILURE. `parameter` is named alongside `punctuation` and MUST
  -- be: it defaults to the punctuation VALUE, not the punctuation ROLE, so a
  -- build moving `punctuation` alone silently leaves parameters behind.
  ["custom-v3"] = {
    palette = {
      punctuation = palette.variants.punctuation.terracotta,
      parameter = palette.variants.punctuation.terracotta,
      bracket = false,
      body = false,
      delimiter = false,
    },
  },
}

local M = {}

---Load one of the builds as a colorscheme.
---@param name string build key: "custom-latest", "custom-v1" .. "custom-v3", "original"
function M.load(name)
  local build = builds[name]
  if not build then
    vim.notify(("solarized-osaka: unknown build %q"):format(tostring(name)), vim.log.levels.ERROR)
    return
  end

  -- Restoring afterwards is load-bearing: these tables are shared, so leaving one
  -- mutated makes a later `:colorscheme` silently keep this build's colours.
  local saved_roles = {}
  for role, value in pairs(build.palette or {}) do
    saved_roles[role] = palette[role]
    palette[role] = value
  end

  -- Reassigned rather than mutated, because the plugin's own `extend()`
  -- reassigns it too and every consumer reads it at call time.
  local plugin_config = build.config and require("solarized-osaka.config") or nil
  local saved_options = plugin_config and plugin_config.options or nil
  if plugin_config then
    plugin_config.options = vim.tbl_deep_extend("force", {}, saved_options, build.config)
  end

  -- The same path the plugin's own colors/solarized-osaka.lua uses, so every
  -- override in init.lua applies exactly as it does by default.
  local ok, err = pcall(function()
    require("solarized-osaka")._load()
  end)

  for role, value in pairs(saved_roles) do
    palette[role] = value
  end
  if plugin_config then
    plugin_config.options = saved_options
  end

  if not ok then
    vim.notify(("solarized-osaka: build %q failed to load: %s"):format(name, err), vim.log.levels.ERROR)
  end

  -- `vim.g.colors_name` is deliberately LEFT as "solarized-osaka". DO NOT "fix"
  -- it to the build name: it is the key plugins look themselves up by, and
  -- lualine resolving `lualine/themes/<colors_name>` silently falls back to a
  -- duller auto theme if renamed. Build names are ENTRY POINTS, not identities.
end

return M
