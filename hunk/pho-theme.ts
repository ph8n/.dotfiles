// BEGIN pho custom theme
// Pho theme for Hunk.
// Colors are sampled from the active Neovim setup:
// github_dark_high_contrast plus the local NormalFloat/Pmenu/statusline overrides.

withLazySyntaxStyle(
  {
    id: "pho",
    label: "Pho",
    appearance: "dark",

    // ── Backgrounds ──────────────────────────────────────────
    background: "#151515",           // Normal is transparent; use NormalFloat/Pmenu base
    panel: "#151515",                // NormalFloat / Pmenu override
    panelAlt: "#151515",             // keep chrome/diff gutters flush with the terminal bg
    border: "#3b4252",               // AxiomStatuslineMeta / subtle UI border

    // ── Accent ───────────────────────────────────────────────
    accent: "#6cb6ff",               // AxiomStatuslineFile / selected tab
    accentMuted: "#1a3858",          // Visual

    // ── Text ─────────────────────────────────────────────────
    text: "#f0f3f6",                 // fg.default
    muted: "#9ea7b3",                // fg.subtle

    // ── Diff: keep rows uniform; only signs and word-level changes pop ──
    addedBg: "#151515",              // no full-line green wash
    removedBg: "#151515",            // no full-line red wash
    contextBg: "#151515",            // editor/terminal background
    addedContentBg: "#17351f",       // minimal word-level add highlight
    removedContentBg: "#3a2023",     // minimal word-level delete highlight
    contextContentBg: "#151515",     // no neutral cell lift

    // ── Git signs ────────────────────────────────────────────
    addedSignColor: "#09b43a",       // GitSignsAdd
    removedSignColor: "#ff6a69",     // GitSignsDelete

    // ── Line numbers ─────────────────────────────────────────
    lineNumberBg: "#151515",         // transparent LineNr gutter on our terminal bg
    lineNumberFg: "#9ea7b3",         // LineNr

    // ── Selection / hunk header ──────────────────────────────
    selectedHunk: "#1a3858",         // Visual

    // ── Badges ───────────────────────────────────────────────
    badgeAdded: "#09b43a",           // GitSignsAdd
    badgeRemoved: "#ff6a69",         // GitSignsDelete
    badgeNeutral: "#9ea7b3",         // LineNr / muted

    // ── File status colors ───────────────────────────────────
    fileNew: "#09b43a",              // GitSignsAdd
    fileDeleted: "#ff6a69",          // GitSignsDelete
    fileRenamed: "#f2cc60",          // AxiomStatuslinePos
    fileModified: "#e09b13",         // GitSignsChange / DiffChange.fg
    fileUntracked: "#9ea7b3",        // LineNr / muted

    // ── Agent notes ──────────────────────────────────────────
    noteBorder: "#6cb6ff",           // accent
    noteBackground: "#182131",       // subdued blue panel
    noteTitleBackground: "#1a3858",  // Visual
    noteTitleText: "#f0f3f6",        // Normal.fg
  },
  // ── Syntax highlighting ──────────────────────────────────
  // sourced from primer prettylights + nvim spec.syntax
  {
    default: "#f0f3f6",             // fg.default  (ident, param, variable, bracket)
    keyword: "#ff9492",             // syntax.keyword (also conditional, statement, preproc)
    string: "#addcff",              // syntax.string (also regex)
    comment: "#bdc4cc",             // Comment
    number: "#91cbff",              // syntax.constant (builtin, const, operator, field)
    function: "#dbb7ff",            // syntax.entity
    property: "#91cbff",            // syntax.constant
    type: "#ffb757",                // syntax.variable
    punctuation: "#f0f3f6",         // Delimiter / Normal.fg
  },
),
// END pho custom theme
