-- Colour VALUES for the solarized-osaka theme. Keys name the ROLE, never a hue.
-- Changing a colour is a one-word edit to the `return` block at the bottom.
--
-- Feeds SYNTAX GROUPS ONLY. `on_colors` in init.lua owns the UI background.
--
-- EVERY value's measurements, verdict and rejection reason live in
-- notes/palette-reference.md -- one table per role, anchored by role name.
-- READ IT BEFORE CHANGING A VALUE. Most obvious ideas are already rejected there
-- with numbers, including four rules that keep being relearned.

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
    subdued = "#aea134", -- LIVE: punctuation + parameter
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
    subtle = "#637981", -- LIVE in custom-latest; reference builds keep upstream
  },

  -- Body text: `Normal`, `NormalFloat`, `@variable`, one value by design.
  body = {
    base0 = "#9eabac", -- LIVE: bracket (custom-latest). The theme's own.
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
    kanagawa_mid = "#96abd3", -- ran 2026-09-07, reverted 09-08
    kanagawa_green = "#8db488",
    kanagawa_saturated = "#90abdd",
    pale_yellow = "#cfcea7",
    pale_cyan = "#9cc8ca",
    kanagawa = "#9cabca",
    warm_taupe = "#b98f79",
    base0 = "#9eabac", -- identical to @variable
    base00 = "#637981", -- sub-AA
    base01 = "#576d74", -- Comment itself. NOT a candidate.
    mid_high = "#7f9195", -- MAXIMIN. LIVE: delimiter.
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
  -- THE LIVE VALUE IS `keyword.subdued`, not anything here.
  punctuation = {
    copper_mid = "#be6421", -- ran 2026-08-11 to 09-05
    terracotta = "#b55f4a", -- custom-v3

    -- Every ladder measured 2026-08-11, kept as ONE group so they are not
    -- rebuilt a fourth time. NOTHING READS THIS. All rejected ON LOOKS despite
    -- measuring well, so judge anything from here on looks, never the numbers.
    explored = {
      clay = "#c16953",
      coral = "#c76e58",
      salmon = "#cd735d", -- tried live 2026-09-08, reverted same session
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

  -- Type, @type.builtin, @constructor. CLOSED 2026-09-07.
  -- The blue band is FULL: String cyan sits at h187 and Function at h250.
  type = {
    sky = "#0edfff",
    sky_calm = "#56cae7",
    sky_soft = "#49ddff",
    sky_softer = "#61dbff",
    sky_dim = "#39cce9",
    tokyonight = "#7dcfff", -- base build
    vscode_entity = "#c0caf5",
    periwinkle = "#a7b1fe",
    nvim_type = "#2ac3de", -- LIVE in custom-latest
    vscode_support = "#0db9d7",
  },

  -- Fields and properties. NOTHING HERE IS APPLIED: the `@variable.member` line
  -- in init.lua is commented out, so member falls back to the theme's cyan500 and
  -- exactly duplicates String. Re-enabling is a one-line uncomment there, but
  -- read the doc first -- these scores predate the keyword move to violet.
  member = {
    rose = "#b67faf", -- the wired default
    iris = "#8d8de3",
    purple = "#a17bcc",
    rose_warm = "#be7ca6",
    rose_cool = "#ac82b7",
    mauve = "#c49ac6",
    violet = "#9b9fec",
    tokyonight = "#73daca",
  },
}

-- THE BASE SELECTIONS. `custom-latest` in variants.lua overrides type, delimiter,
-- bracket and func; every other build starts from these values.
--
-- WARN: SILENT FAILURE. Three traps in this block, all verified:
--   1. A build role must be `false`, NEVER `nil`. `nil` is the absence of a key,
--      so `variants.load` iterates with `pairs`, never sees it, and the override
--      silently does not happen. Applies to `delimiter`, `body`, `bracket`.
--   2. A duplicate role key here is not an error -- the last assignment wins and
--      the earlier line becomes a lie that reordering would activate. Happened
--      2026-09-06 with `delimiter`. After editing a role, check it appears once:
--        grep -c "^  delimiter = " lua/colorschemes/solarized-osaka/palette.lua
--   3. `false` on `comment` is meaningful: it keeps upstream comments in
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
  -- UNREAD: see `member` above.
  member = variants.member.rose,
}
