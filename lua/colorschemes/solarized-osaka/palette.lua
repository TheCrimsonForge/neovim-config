-- Colour VALUES for the solarized-osaka theme. Keys name the ROLE, never a hue.
-- Changing a colour is a one-word edit to the `return` block at the bottom.
--
-- Feeds SYNTAX GROUPS ONLY. `on_colors` in init.lua owns the UI background.
--
-- EVERY value's measurements, verdict and rejection reason live in
-- notes/palette-reference.md -- one table per role, anchored by role name.
-- READ IT BEFORE CHANGING A VALUE. Most obvious ideas are already rejected there
-- with numbers, including four rules that keep being relearned.
--
-- WHAT IS ACTUALLY ON SCREEN IS NOT DECIDED HERE. The `return` block at the
-- bottom sets the BASE defaults, and `custom-latest` in variants.lua overrides
-- any of them -- so that build is the authority, and comments in this file
-- describe candidates and base defaults, never "what I am looking at". A note
-- here claiming otherwise has probably gone stale; read variants.lua, or dump
-- the truth from a running editor:
--   :lua =vim.api.nvim_get_hl(0,{name='@boolean',link=false})

local variants = {
  -- Keyword, Statement, @keyword, @keyword.operator, @label.
  -- Densest capture in the daily stack. STOP RULE: re-measure past ~7% of ink.
  keyword = {
    warm_violet = "#a17bcc", -- SELECTED
    kanagawa = "#957fb8",
    tokyonight = "#9d7cd8",
    warm_rose = "#b67faf",
    tokyonight_magenta = "#bb9af7",
    catppuccin_mauve = "#cba6f7",
    olive = "#849900",
    balanced = "#aea10c", -- custom-v2
    darker = "#a3970b",
    brighter = "#baac0d",
    amber = "#b59a00",
    citron = "#9ea100",
    subdued = "#aea134", -- the yellow; base default for punctuation + parameter
    hushed = "#aea042",
    gold = "#b99004",
    drab = "#8c9644",
    verdant = "#5da100",
    sage = "#66985e",
    moss = "#629959",
    fern = "#5d9a53",
    clover = "#599e49",
    juniper = "#569f41",
    leaf = "#4ea339",
    grass = "#56a325",
  },

  -- Lua's `end` / `then` / `do`. REJECTED WHOLESALE 2026-08-09 and NOTHING READS
  -- THIS TABLE. Reopening needs after/queries/lua/highlights.scm back; read the
  -- doc first, the experiment already failed twice.
  keyword_grammar = {
    cool_grey = "#75878a", -- the wired default
    base00 = "#637981",
    fg = "#839395",
    warm_grey = "#888474",
    bronze = "#8b8465",
    base0 = "#9eabac",
  },

  comment = {
    subtle = "#637981", -- 4.15:1. NOT applied unless a build sets `comment`; the
    -- base leaves it `false`, so comments are upstream #576d74 by default
  },

  -- Body text: `Normal`, `NormalFloat`, `@variable`, one value by design.
  body = {
    base0 = "#9eabac", -- the theme's own; also the pre-2026-09-05 @variable value
    base1 = "#adb7b7",
    brighter = "#b1bebf", -- SELECTED
    brightest = "#bcc9ca",
    base2 = "#ede7d3",
  },

  -- Operators and delimiters. `mid_high` IS THE MAXIMIN RUNG: past it, every step
  -- buys comment separation by giving up more body separation, so "make it
  -- brighter to distinguish it better" is FALSE above it. The `mid*` rungs are
  -- synthesised on the theme's grey axis. Ladder + rejected colour sweep in the
  -- doc; do not rebuild it.
  delimiter = {
    kanagawa_mid = "#96abd3", -- LCh midpoint of the two Kanagawa blues below
    kanagawa_green = "#8db488",
    kanagawa_saturated = "#90abdd",
    pale_yellow = "#cfcea7",
    pale_cyan = "#9cc8ca",
    kanagawa = "#9cabca",
    warm_taupe = "#b98f79",
    base0 = "#9eabac", -- identical to @variable
    base00 = "#637981", -- sub-AA
    base01 = "#576d74", -- Comment itself. NOT a candidate.
    mid_high = "#7f9195", -- MAXIMIN rung; base default for delimiter + bracket
    mid = "#798c91",
    mid_low = "#73878d",
    brighter = "#859699",
    brightest = "#8b9b9e",
  },

  -- Special, Debug, @punctuation.bracket, @variable.builtin, JSX tags,
  -- @keyword.import, and via `parameter` also @variable.parameter/@constructor.
  --
  -- Densest accent in the palette (19.1% of ink in markup-heavy TSX) and the warm
  -- side of the screen on its own.
  --
  -- HARD CONSTRAINT: stay clear of the error red #ff3b30 (set in init.lua) so
  -- brackets never read as diagnostics. Chroma does that work, not hue.
  --
  -- NOTE: the base default for this role is `keyword.subdued`, not anything in
  -- this table. Builds override it freely -- check variants.lua for what is live.
  punctuation = {
    copper_mid = "#be6421", -- ran 2026-08-11 to 09-05
    terracotta = "#b55f4a", -- custom-v3

    -- Every ladder measured 2026-08-11, kept as ONE group so they are not
    -- rebuilt a fourth time. NOTHING READS THIS. All rejected ON LOOKS despite
    -- measuring well, so judge anything from here on looks, never the numbers.
    explored = {
      clay = "#c16953",
      coral = "#c76e58",
      salmon = "#cd735d", -- taken up 2026-09-08 for punctuation/parameter/member
      sunset = "#cf7163",
      blush = "#d16f68",
      dusty_rose = "#d16e6c",
      copper_soft = "#ba662b",
      copper_warm = "#c26116",
      copper = "#cb6001", -- LIVE on CursorLineNr
      ember = "#c85c27",
      sienna_hot = "#d85d13",
      balanced_amber = "#a67136",
      solarized_orange = "#cb4b16",
    },

    -- Untried in place.
    tokyonight = "#f7768e",
    muted_contrast = "#c75b6b",
    crimson = "#bf2c47",
    magenta = "#b02669",
    vivid = "#e03857",
    bright = "#ab3a4f",
    lighter = "#b83e55",
    darker = "#993141",
    red300 = "#f6524f",
    red700 = "#b7211f",
  },

  -- Function, Identifier, @markup.link.
  func = {
    azure = "#1d98cd", -- base build
    vivid = "#359ee9", -- LIVE in custom-latest
    deeper = "#2797e7",
    brighter = "#268bd2",
    blue300 = "#49aef5",
    balanced = "#4488ab",
  },

  -- Type, @type.builtin, @constructor.
  --
  -- THE BLUE BAND IS FULL: String cyan sits at h187 and Function at h250, and
  -- type has to fit between them. String is only 33 degrees away in hue, so what
  -- separates the two is LIGHTNESS -- which is why this role cannot simply be
  -- dimmed, and why low chroma does not work either (at L* 70 with C* 24 it
  -- starts colliding with the greys instead).
  --
  -- Type is also the BRIGHTEST accent and the 3rd densest capture (14.75% of a
  -- real api.ts, 20.33% of a type-heavy file), which is a standing rule-3
  -- conflict. Reviewed 2026-09-08 for exactly that; see the doc for the four
  -- options measured and why yellow was rejected outright.
  type = {
    sky = "#0edfff",
    sky_calm = "#56cae7",
    sky_soft = "#49ddff",
    sky_softer = "#61dbff",
    sky_dim = "#39cce9",
    tokyonight = "#7dcfff", -- base build
    vscode_entity = "#c0caf5",
    periwinkle = "#a7b1fe",
    nvim_type_dim = "#17bbd6", -- L*69.9 C*37.7 8.25:1 | SELECTED 2026-09-08: nvim_type at L* 70
    nvim_type = "#2ac3de", -- L*72.8 C*37.8 9.02:1 | ran 2026-09-07 to 09-08; brightest accent on screen
    vscode_support = "#0db9d7",
  },

  -- Booleans and `@constant`, painted via `Boolean` / `@constant` in init.lua.
  -- Modelled on Tokyo Night's orange by reproducing its RELATIONSHIP (7.9 L*
  -- below body text), not its hex, so every value here sits at L* 68.
  --
  -- What picks the value is separation from the DENSE warm role, and TN's own
  -- hue loses there -- see notes/palette-reference.md, "boolean".
  boolean = {
    amber = "#d19c59", -- L*68.1 C*44.1 h73.8 7.80:1 | SELECTED: dE 27.4 / 34deg from salmon, still reads warm
    gold = "#b5a73b", -- L*67.9 C*55.9 h97.9 7.75:1 | dE 50.3 / 58deg -- MAX clarity, but yellow not orange
    tokyonight_dim = "#ed8e55", -- L*68.0 C*54.8 h55.5 7.79:1 | TN's hue at our lightness; dE only 20.2 / 16deg from salmon -- BLURRED, reported 2026-09-08
    tokyonight = "#ff9e64", -- L*74.0 C*54.6 h55.6 9.35:1 | TN as shipped; dE 23.7 / 16deg, same hue problem and -2.1 L* vs body
  },

  -- Member fields (`@variable.member`), APPLIED since 2026-09-08. Before that
  -- init.lua painted nothing with it, so setting `member` in a build silently did
  -- nothing. `@property` (object/dict keys, JSX attrs) is a separate group and
  -- still on the theme default, where it duplicates Function.
  --
  -- These scores predate the keyword move to violet, so re-measure anything
  -- close to keyword. Stay IN the accent band (L* ~60): these symbols appear on
  -- nearly every line, and a bright value drains its neighbours.
  member = {
    rose = "#b67faf", -- base-build default
    iris = "#8d8de3",
    purple = "#a17bcc",
    rose_warm = "#be7ca6",
    rose_cool = "#ac82b7",
    mauve = "#c49ac6",
    violet = "#9b9fec",
    tokyonight = "#73daca",
  },
}

-- THE BASE SELECTIONS. `custom-latest` in variants.lua overrides several of
-- these; every other build starts from the values below.
--
-- THE SHAPE: four lightness steps ordered by how much the thing means -- body
-- 76.0, names 65.5, punctuation 62.8/58.9, comments 44.6 -- with EXACTLY ONE
-- ACCENT HUE ON THE WARM SIDE instead of two.
--
-- That last clause is the one people break. Re-confirmed 2026-09-08: yellow
-- punctuation beside a salmon `member` was rejected on sight, and total warm ink
-- was IDENTICAL either way -- so it is not a dose problem and no hex retune
-- fixes it. Keep the warm side to one dominant hue plus at most one LOW-DOSE
-- accent. Measurements: notes/palette-reference.md, "One accent hue".
--
-- WARN: SILENT FAILURE. Three traps here, all verified:
--   1. A build role must be `false`, NEVER `nil` -- `nil` is an absent key, so
--      `variants.load`'s `pairs` never sees it and the override does not happen.
--   2. A duplicate role key is not an error; the last assignment wins silently.
--      After editing a role: grep -c "^  delimiter = " <this file>
--   3. `false` on `comment` is meaningful -- it keeps upstream comments in
--      reference builds and prevents override leakage.
return {
  -- Exposed by role so builds can name a value without copying a hex. Read only
  -- by variants.lua; costs nothing, the table is built either way.
  variants = variants,

  keyword = variants.keyword.warm_violet,
  -- UNREAD: the grammar-dimming experiment was rejected and init.lua paints
  -- nothing with it. Kept wired so the values stay measured.
  keyword_grammar = variants.keyword_grammar.cool_grey,
  -- Yellow replaced copper 2026-09-05, reaffirmed 2026-09-08.
  punctuation = variants.keyword.subdued,
  -- Parameter names and `new X()` callees. Holds the same yellow: what separates
  -- a parameter from its brackets is the BRACKET being neutral, not the hue.
  parameter = variants.keyword.subdued,
  -- `false` here would mean "follow the theme's own base0" -- init.lua reads
  -- `palette.delimiter or c.base0`.
  delimiter = variants.delimiter.mid_high,
  body = variants.body.brighter,
  comment = false,
  -- Brackets are the same "punctuation carrying no meaning worth a hue" class as
  -- `Operator`, which is what lets a yellow name sit inside neutral punctuation.
  -- Separate from `delimiter` so a build can split the two; custom-latest does.
  bracket = variants.delimiter.mid_high,
  func = variants.func.azure,
  type = variants.type.tokyonight,
  -- Booleans. Painted by `hl.Boolean` in init.lua, which `@boolean` links to.
  boolean = variants.boolean.amber,
  -- UNREAD: see `member` above.
  member = variants.member.rose,
}
