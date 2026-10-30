-- Searchable keyboard reference for this WezTerm configuration.
-- InputSelector is a native WezTerm UI, so use clean text dividers and alignment
-- rather than ANSI colors or terminal escape sequences.

local choices = {
   { label = '╭──────────────────────────────────────────────────────────────╮' },
   { label = '│                  WEZTERM KEYBOARD SHORTCUTS                  │' },
   { label = '│                 Type to filter  •  Esc to close               │' },
   { label = '╰──────────────────────────────────────────────────────────────╯' },

   { label = ' ' },
   { label = '━━━━  PANE MANAGEMENT  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' },
   { label = 'Alt + Q                 Split pane left' },
   { label = 'Alt + E                 Split pane right' },
   { label = 'Alt + R                 Split pane down' },
   { label = 'Alt + T                 Split pane up' },
   { label = 'Shift + ← / → / ↑ / ↓   Focus adjacent pane' },
   { label = 'Alt + Shift + Arrows    Resize active pane' },
   { label = 'Alt + Enter             Zoom / unzoom active pane' },
   { label = 'Alt + W                 Close active pane' },

   { label = ' ' },
   { label = '━━━━  TABS & WINDOWS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' },
   { label = 'Alt + 0                 New default shell tab' },
   { label = 'Ctrl + Alt + T          New Ubuntu WSL tab' },
   { label = 'Alt + 1–9               Switch to tab 1–9' },
   { label = 'Ctrl + Alt + W          Close current tab' },
   { label = 'Alt + [ / ]             Previous / next tab' },
   { label = 'Alt + N                 New window' },
   { label = 'F2                      Command palette' },
   { label = 'F3 / F4 / F5            Launcher / tabs / workspaces' },
   { label = 'F6                      Open this keyboard reference' },
   { label = 'F11 / F12               Fullscreen / debug overlay' },

   { label = ' ' },
   { label = '━━━━  VIM-STYLE COPY MODE  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' },
   { label = 'Alt + G                 Enter WezTerm copy mode' },
   { label = 'h / j / k / l           Move left / down / up / right' },
   { label = 'g / Shift + G           Top / bottom of scrollback' },
   { label = 'w / b / e               Move by words' },
   { label = '0 / $                   Start / end of line' },
   { label = 'v                       Start character selection' },
   { label = 'Shift + V               Select whole lines' },
   { label = 'y                       Copy selection and exit' },
   { label = 'q / Esc                 Exit copy mode' },

   { label = ' ' },
   { label = '━━━━  SEARCH & CLIPBOARD  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' },
   { label = 'Alt + F                 Search terminal scrollback' },
   { label = 'Ctrl + Shift + C        Copy' },
   { label = 'Ctrl + Shift + V        Paste' },
   { label = 'Ctrl + Alt + U          Quick-select and open URL' },
   { label = 'Ctrl + Click            Open link under mouse' },

   { label = ' ' },
   { label = '━━━━  BACKGROUNDS & MISC  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' },
   { label = 'Alt + /                 Random background' },
   { label = 'Alt + , / .             Previous / next background' },
   { label = 'Ctrl + Alt + /          Choose background' },
   { label = 'Alt + B                 Toggle background focus' },
   { label = 'PageUp / PageDown       Scroll by page' },
}

return { choices = choices }
