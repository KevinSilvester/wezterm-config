local wezterm = require("wezterm")

local custom = {
  base = '#1e1e28',
}


-- color variant hex codes
local colors = {
  latte = {
    rosewater = "#dc8a78",
    flamingo = "#dd7878",
    pink = "#ea76cb",
    mauve = "#8839ef",
    red = "#d20f39",
    maroon = "#e64553",
    peach = "#fe640b",
    yellow = "#df8e1d",
    green = "#40a02b",
    teal = "#179299",
    sky = "#04a5e5",
    sapphire = "#209fb5",
    blue = "#1e66f5",
    lavender = "#7287fd",
    text = "#4c4f69",
    subtext1 = "#5c5f77",
    subtext0 = "#6c6f85",
    overlay2 = "#7c7f93",
    overlay1 = "#8c8fa1",
    overlay0 = "#9ca0b0",
    surface2 = "#acb0be",
    surface1 = "#bcc0cc",
    surface0 = "#ccd0da",
    crust = "#dce0e8",
    mantle = "#e6e9ef",
    base = "#eff1f5",
  },
  frappe = {
    rosewater = "#f2d5cf",
    flamingo = "#eebebe",
    pink = "#f4b8e4",
    mauve = "#ca9ee6",
    red = "#e78284",
    maroon = "#ea999c",
    peach = "#ef9f76",
    yellow = "#e5c890",
    green = "#a6d189",
    teal = "#81c8be",
    sky = "#99d1db",
    sapphire = "#85c1dc",
    blue = "#8caaee",
    lavender = "#babbf1",
    text = "#c6d0f5",
    subtext1 = "#b5bfe2",
    subtext0 = "#a5adce",
    overlay2 = "#949cbb",
    overlay1 = "#838ba7",
    overlay0 = "#737994",
    surface2 = "#626880",
    surface1 = "#51576d",
    surface0 = "#414559",
    base = "#303446",
    mantle = "#292c3c",
    crust = "#232634",
  },
  macchiato = {
    rosewater = "#f4dbd6",
    flamingo = "#f0c6c6",
    pink = "#f5bde6",
    mauve = "#c6a0f6",
    red = "#ed8796",
    maroon = "#ee99a0",
    peach = "#f5a97f",
    yellow = "#eed49f",
    green = "#a6da95",
    teal = "#8bd5ca",
    sky = "#91d7e3",
    sapphire = "#7dc4e4",
    blue = "#8aadf4",
    lavender = "#b7bdf8",
    text = "#cad3f5",
    subtext1 = "#b8c0e0",
    subtext0 = "#a5adcb",
    overlay2 = "#939ab7",
    overlay1 = "#8087a2",
    overlay0 = "#6e738d",
    surface2 = "#5b6078",
    surface1 = "#494d64",
    surface0 = "#363a4f",
    base = "#24273a",
    mantle = "#1e2030",
    crust = "#181926",
  },
  mocha = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f5c2e7",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#89dceb",
    sapphire = "#74c7ec",
    blue = "#89b4fa",
    lavender = "#b4befe",
    text = "#cdd6f4",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#45475a",
    surface0 = "#313244",
    -- base = "#1e1e2e",
    base = custom.base,
    mantle = "#181825",
    crust = "#11111b",
  },
}

local items = {
  tab_bar = {
    background = '#000000',
    inactive_tab = {
      bg_color = colors.mocha.surface0,
      fg_color = '#bac2de',
    },
    inactive_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
    },
  }
}

local catppuccin = {}
function catppuccin.select(palette)
  -- shorthand to check for the Latte flavour
  local isLatte = palette == "latte"

  return {
    foreground = colors[palette].text,
    background = colors[palette].base,
    cursor_bg = colors[palette].rosewater,
    cursor_border = colors[palette].rosewater,
    cursor_fg = isLatte and colors[palette].base or colors[palette].crust,
    selection_bg = colors[palette].surface2,
    selection_fg = colors[palette].text,
    ansi = {
      isLatte and colors[palette].subtext1 or colors[palette].surface1,
      colors[palette].red,
      colors[palette].green,
      colors[palette].yellow,
      colors[palette].blue,
      colors[palette].pink,
      colors[palette].teal,
      isLatte and colors[palette].surface2 or colors[palette].subtext1,
    },
    brights = {
      isLatte and colors[palette].subtext0 or colors[palette].surface2,
      colors[palette].red,
      colors[palette].green,
      colors[palette].yellow,
      colors[palette].blue,
      colors[palette].pink,
      colors[palette].teal,
      isLatte and colors[palette].surface1 or colors[palette].subtext0,
    },
    tab_bar = {
      -- background = colors[palette].crust,
      background = items.tab_bar.background,
      active_tab = {
        bg_color = colors[palette].surface2,
        fg_color = colors[palette].text,
      },
      -- inactive_tab = {
      --    bg_color = colors[palette].mantle,
      --    fg_color = colors[palette].text,
      -- },
      -- inactive_tab_hover = {
      --    bg_color = colors[palette].mantle,
      --    fg_color = colors[palette].text,
      -- },
      inactive_tab = items.tab_bar.inactive_tab,
      inactive_tab_hover = items.tab_bar.inactive_tab_hover,
      new_tab = {
        bg_color = colors[palette].base,
        fg_color = colors[palette].text,
      },
      new_tab_hover = {
        bg_color = colors[palette].mantle,
        fg_color = colors[palette].text,
        italic = true,
      },
    },
    visual_bell = colors[palette].surface0,
    indexed = {
      [16] = colors[palette].peach,
      [17] = colors[palette].rosewater,
    },
    scrollbar_thumb = colors[palette].surface2,
    split = colors[palette].overlay0,
    -- nightbuild only
    compose_cursor = colors[palette].flamingo,
  }
end

-- utility functions for interacting with wezterm API
local function scheme_for_appearance(appearance, options)
  if appearance:find("Dark") then
    return catppuccin.select(options.sync_flavours.dark)
  else
    return catppuccin.select(options.sync_flavours.light)
  end
end

function catppuccin.setup(options)
  -- default to not syncing with the OS theme
  local should_sync = true
  if options.sync == false then
    should_sync = false
  end

  -- default options
  options = {
    sync = should_sync,
    sync_flavours = options.sync_flavours or {
      light = "latte",
      dark = "mocha",
    },
    flavour = options.flavour or "mocha",
  }

  -- if sync is enabled, hook into the window-config-reloaded event
  -- snippet from https://wezfurlong.org/wezterm/config/lua/window/get_appearance.html#windowget_appearance
  if options.sync then
    wezterm.on("window-config-reloaded", function(window, pane)
      local overrides = window:get_config_overrides() or {}
      local appearance = window:get_appearance()
      local scheme = scheme_for_appearance(appearance, options)
      if overrides.background ~= scheme.background then
        overrides.colors = scheme
        window:set_config_overrides(overrides)
      end
    end)
  end

  return catppuccin.select(options.flavour)
end

return catppuccin
