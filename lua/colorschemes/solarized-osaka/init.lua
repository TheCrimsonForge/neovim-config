-- Which highlight groups get the palette's colours, plus the UI-chrome overrides
-- that are not syntax at all. Colour VALUES live in palette.lua.
--
-- WHY EACH BLOCK BELOW EXISTS -- the measurements, the grammar traps, the
-- rejected alternatives and the "do not tune this" notes -- is in
-- notes/palette-reference.md, sections "Grammar traps" and "UI highlights".
-- Read it before changing a group list or a chrome value.
local palette = require("colorschemes.solarized-osaka.palette")

return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- WARN: SILENT FAILURE. Must be an explicit `false`. The plugin defaults
    -- `transparent` to `true`, so deleting or commenting this line re-enables
    -- transparency rather than disabling it. Opaque since 2026-09-04.
    transparent = false,
    -- ONE background for the whole editor, from lua/config/ui.lua. The ONE
    -- legitimate `on_colors` -- it does not reopen the syntax-ramp ban below.
    -- All three keys, or floats and sidebars show as panels that do not match.
    --
    -- WARN: SILENT NO-OP. `bg_popup` and `bg_statusline` are deliberately NOT
    -- set and must stay unset -- neither is the key it looks like, and the
    -- completion menu depends on `bg_popup` staying base04. Both measured.
    on_colors = function(c)
      local bg = require("config.ui").bg
      c.bg = bg
      c.bg_float = bg
      c.bg_sidebar = bg
    end,
    -- NO `on_colors` FOR SYNTAX. The theme's base ramp (green500, orange500,
    -- blue500, cyan500) is shared with the UI, so a syntax choice there silently
    -- repaints git signs, diagnostics, the dashboard and indent guides. That is
    -- how the keyword colour turned git-added markers yellow on 2026-08-08.
    on_highlights = function(hl, c)
      -- Merge `fg` so a group keeps its italic/bold/underline/background.
      --
      -- WARN: SILENT FAILURE. Values here are heterogeneous -- a highlight table
      -- OR a bare string, the theme's shorthand for a link. Merging into a
      -- string throws; a link needs no help, its target is in the same list.
      local function paint(groups, fg)
        for _, g in ipairs(groups) do
          if type(hl[g]) == "table" then
            hl[g] = vim.tbl_extend("force", hl[g], { fg = fg })
          elseif hl[g] == nil then
            hl[g] = { fg = fg }
          end
        end
      end

      -- Both roles read `false` as "follow the theme's own ramp", which is why a
      -- build must write `false` and never `nil`. See palette.lua.
      local delimiter = palette.delimiter or c.base0

      local bracket = palette.bracket or palette.punctuation

      -- Painted rather than left to the theme so a build can raise body text.
      -- `paint` merges, so `Normal` keeps its background. The other 15 groups the
      -- theme puts on base0 are chrome and stay put.
      if palette.body then
        paint({ "Normal", "NormalFloat", "@variable" }, palette.body)
      end

      -- Lift syntax comments without changing base01, which also colors UI chrome.
      if palette.comment then
        paint({ "Comment" }, palette.comment)
      end

      -- The winbar sits on the editor background, not the statusline's (the theme
      -- links WinBar -> StatusLine, bg base03, which reads as a lighter strip).
      hl.WinBar = { link = "Normal" }
      hl.WinBarNC = { link = "NormalNC" }

      -- `Operator` is deliberately NOT here, but `@keyword.operator` (`and`,
      -- `or`, `not`) is: those are keywords spelled as operators.
      paint({
        "Statement",
        "Keyword",
        "@keyword",
        "@keyword.function",
        "@label",
        "@keyword.tsx",
        "@keyword.return.tsx",
        "@keyword.javascript",
        "@keyword.return.javascript",
      }, palette.keyword)

      paint({
        "Special",
        "Debug",
        "@variable.builtin",
        "@module.builtin",
        -- JSX tags are painted in their own block below. Same colour.
      }, palette.punctuation)

      paint({ "@punctuation.bracket" }, bracket)

      -- `${}` is a MODE SWITCH, not structure, so it keeps the accent -- and it
      -- has to stay readable INSIDE the string colour, which the neutral grey
      -- does not (17.7 separation against this accent's 32.9).
      paint({ "@punctuation.special" }, palette.punctuation)

      paint({
        "@variable.parameter",
        "@constructor",
        "@constructor.tsx",
      }, palette.parameter)

      -- Lua captures `{` as BOTH @punctuation.bracket and @constructor, so this
      -- pin is what stops a `palette.parameter` change recolouring every Lua
      -- table brace. Language-scoped: @constructor.lua resolves first.
      paint({ "@constructor.lua" }, bracket)

      -- JSX tag NAMES. Both captures MUST carry the same value -- the grammar
      -- matches one tag with BOTH and query order picks the winner, so splitting
      -- them renders `<DragAndDrop.Droppable>` in two colours. @tag.builtin.* is
      -- listed explicitly so theme drift cannot bring that back.
      --
      -- Language-scoped, so nothing here reaches Go/Python/Lua/bash/plain TS.
      -- KNOWN COST: 30.2% of glyphs in markup-heavy TSX. That is a DOSE problem,
      -- not a colour problem -- retuning the hex cannot change coverage.
      paint({
        "@tag.tsx",
        "@tag.javascript",
        "@tag.builtin.tsx",
        "@tag.builtin.javascript",
      }, palette.punctuation)

      -- Tag wrappers (`<`, `>`, `/`) stay on base0 by user preference, so dense
      -- markup gets a quieter frame. Keep language-scoped: ordinary comparison
      -- and division operators still follow the syntax palette.
      paint({
        "@tag.delimiter.tsx",
        "@tag.delimiter.vue",
        "@tag.delimiter.html",
        "@tag.delimiter.javascript",
      }, c.base0)

      -- This group is `,` `;` `:` AND the `.` of every member access, so on the
      -- keyword colour it put an accent mark on nearly every line of Go and TS.
      paint({ "@punctuation.delimiter" }, delimiter)

      -- Written as tables because `paint` skips bare string links, and these two
      -- link OUTSIDE the lists above, so skipping would leave them resolving
      -- wrong: @keyword.import -> PreProc -> an alarm red that reads as a
      -- diagnostic, and @keyword.operator -> Operator, which goes neutral below.
      hl["@keyword.import"] = { fg = palette.punctuation }
      hl["@keyword.operator"] = { fg = palette.keyword }

      -- Nothing paints Lua's grammar keywords, deliberately: that was tried
      -- twice in 2026-08-09 and rejected wholesale. See palette.lua.

      -- No markup/markdown groups in any of these lists, on purpose: markdown is
      -- prose and keeps the theme's own colours. Exclusion list in the doc.
      paint({
        "Function",
        "Identifier",
      }, palette.func)

      -- The theme overrides `@variable.typescript`/`.javascript` yellow but has
      -- no `.tsx`/`.jsx` equivalent, so `.ts` variables were yellow while `.tsx`
      -- stayed white. Link both back to `@variable`.
      hl["@variable.typescript"] = { link = "@variable" }
      hl["@variable.javascript"] = { link = "@variable" }

      -- Symbolic operators go neutral. The theme paints Operator with the keyword
      -- colour, which is what made that colour feel brighter in some files but
      -- not others -- measured at an 11x coverage spread between two Lua files in
      -- the same repo. `=` is punctuation, not a keyword. `and`/`or`/`not` are
      -- the exception and stay on the keyword list above, which must come after
      -- this or it reaches them via @keyword.operator -> @operator -> Operator.
      hl.Operator = { fg = delimiter }

      -- Native CSS fallback: reuse syntax roles instead of Function/PreProc/Noise.
      -- Explicit links survive css.vim's later `hi def link` without buffer hooks.
      -- Function regions supply the colour of otherwise uncaptured calc operators.
      for group, target in pairs({
        cssBraces = "@punctuation.bracket",
        cssMathParens = "@punctuation.bracket",
        cssNoise = "@punctuation.delimiter",
        cssClassNameDot = "@punctuation.delimiter",
        cssAttrComma = "@punctuation.delimiter",
        cssFunctionComma = "@punctuation.delimiter",
        cssMediaComma = "@punctuation.delimiter",
        cssSelectorOp = "Operator",
        cssSelectorOp2 = "Operator",
        cssFunction = "Operator",
        cssMathGroup = "Operator",
        cssAtRule = "@keyword",
        cssAtKeyword = "@keyword",
        cssAtRuleLogical = "@keyword",
        cssPseudoClass = "@keyword",
        cssPseudoClassId = "@keyword",
        cssPagePseudo = "@keyword",
      }) do
        hl[group] = { link = target }
      end

      -- Setting the base group is the whole fix: @type, @type.builtin,
      -- @type.definition, Typedef, Structure and every @lsp.type.* link to it.
      hl.Type = { fg = palette.type }

      -- Fields and properties are BOTH left at the theme default, so both exactly
      -- duplicate another role (@variable.member == String, @property ==
      -- Function). Knowingly: rose won on measurement but not on looks in large
      -- files. Re-enabling is this one-line uncomment; read the doc first.
      -- hl["@variable.member"] = { fg = palette.member }

      -- @module links to PreProc -> an alarm red 31 degrees from the error red,
      -- so imports read as diagnostics in every language except Go.
      hl["@module"] = { fg = c.base2 }

      hl.Visual = { bg = "#3b4261" }
      hl.VisualNOS = { bg = "#3b4261" }

      -- The theme's `yellow700` gutter is a CHROMA problem, not a lightness one:
      -- it read as content competing with code. #2d3f43 is a low-chroma cool grey
      -- on the background's own hue. If too dim, #33474b is the one step up --
      -- DO NOT go back toward a saturated hue, raise lightness and keep C* < 10.
      -- All three carry explicit values in the theme, so all three must be set.
      hl.LineNr = { fg = "#2d3f43" }
      hl.LineNrAbove = { fg = "#2d3f43" }
      hl.LineNrBelow = { fg = "#2d3f43" }

      -- Re-enable with a custom color (e.g. "#073642") to restore the band.
      hl.CursorLine = { bg = "NONE" }

      -- if u want to change the current line number indicator color , can change here
      hl.CursorLineNr = {
        fg = palette.variants.punctuation.explored.copper,
      }
      -- Oil-only current-row band, since CursorLine is off globally. Oil remaps
      -- CursorLine -> OilCursorLine via winhighlight.
      hl.OilCursorLine = { bg = c.base02 }

      -- Markdown headings only. The GENERIC @markup.heading links to `Title`,
      -- which help files, pickers and `:set all` share -- so override the
      -- markdown-specific variants instead. render-markdown leaves heading fg to
      -- treesitter, so this is what paints them.
      for level = 1, 6 do
        hl["@markup.heading." .. level .. ".markdown"] = { fg = c.green, bold = true }
      end

      -- LSP doc surface. Separation comes from the border and foreground, not the
      -- background: a raised panel was tried and read as a box pasted over the
      -- editor, and there is no darker bg to reach for. Deliberately NOT applied
      -- to NormalFloat, which would repaint the snacks picker; these are reached
      -- only by doc floats, via winhighlight in config/keymaps.lua.
      --
      -- `fg` paints the description PROSE and essentially nothing else. DO NOT go
      -- dimmer -- the next ramp step is sub-AA and sits 5 L* off Comment, so
      -- there is exactly one usable value here. Border and title need DIFFERENT
      -- weights: border is chrome at 2.33:1, title is text and follows the
      -- keyword so it keeps tracking the palette.
      hl.LspDocFloat = { fg = c.fg, bg = c.bg_float }
      hl.LspDocBorder = { fg = c.yellow700, bg = c.bg_float }
      hl.LspDocTitle = { fg = palette.keyword, bg = c.bg_float, bold = true }

      -- Inline code chips in a hover doc. The theme's yellow-on-dark-green fill
      -- reads as amber boxes in a float with no other background. Same colour
      -- CodeCompanion uses, so chips match between chat and LSP doc. Scoped via
      -- winhighlight in config/keymaps.lua, because that capture is also every
      -- inline span in a real .md file.
      hl.LspDocInlineCode = { fg = "#8ab4d8", bg = "NONE" }

      -- Completion menu family: `c.bg_popup`, NOT `c.bg_float`. Since 2026-09-04
      -- `bg_float` is the shared editor background, which left the menu with no
      -- panel of its own. `bg_popup` is still base04 and is the right key -- these
      -- are popups, not floats.
      hl.BlinkCmpDoc = { fg = c.base1, bg = c.bg_popup }
      hl.BlinkCmpDocBorder = { fg = palette.type, bg = c.bg_popup }

      hl.BlinkCmpMenu = { fg = c.base1, bg = c.bg_popup }
      hl.BlinkCmpMenuBorder = { fg = c.base02, bg = c.bg_popup }
      hl.BlinkCmpMenuSelection = { fg = c.base2, bg = c.base02, bold = true }
      hl.BlinkCmpLabel = { fg = c.base1, bg = c.none }
      hl.BlinkCmpLabelMatch = { fg = c.blue300, bg = c.none }

      hl.Pmenu = { fg = c.base1, bg = c.bg_popup }
      hl.PmenuSel = { fg = c.base2, bg = c.base02, bold = true }
      hl.PmenuSbar = { bg = c.bg_highlight }
      hl.PmenuThumb = { bg = c.base01 }

      hl.DiagnosticVirtualTextError = { fg = "#ff3b30", bg = c.none }
      hl.DiagnosticVirtualTextWarn = { fg = "#e0af68", bg = c.none }
      hl.DiagnosticVirtualTextInfo = { bg = c.none }
      hl.DiagnosticVirtualTextHint = { fg = "#1abc9c", bg = c.none }

      hl.Folded = { bg = "NONE" }
      hl.UfoFoldedBg = { bg = "NONE" }

      -- grug-far match. Defaults to DiffText, a near-black green band here, so
      -- the match looks faded. Cyan deliberately, so it never reads like a vim
      -- `/` hit (Search is yellow, IncSearch muted rose-red).
      hl.GrugFarResultsMatch = { fg = c.base04, bg = c.cyan300, bold = false }

      -- grug-far summary. Defaults to Comment, too dim against the panel.
      hl.GrugFarResultsStats = { fg = c.base2 }

      -- TODO: brighten the snacks picker match highlight (currently a faded
      -- olive band). Setting `hl.SnacksPickerMatch` here does NOT take effect --
      -- something re-applies it to `DiffText` AFTER this on_highlights runs
      -- (snacks registers picker hl groups lazily on its own ColorScheme hook).
      -- Needs a late ColorScheme autocmd or the snacks plugin spec instead.
      -- Scope: snacks picker only.
    end,
  },
}
