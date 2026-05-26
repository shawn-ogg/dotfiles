local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find("darwin") ~= nil

local leader_mod = is_macos and 'CMD' or 'SUPER'

local hyper_mods =
  is_macos
  and 'SHIFT|CTRL|ALT|CMD'
  or 'SHIFT|CTRL|ALT|SUPER'

-- Appearance ---------------------------------------------------------------

config.color_scheme = 'Twilight (dark) (terminal.sexy)'
config.font = wezterm.font('Hack Nerd Font')
config.font_size = 14
config.default_cursor_style = 'BlinkingBar'

config.initial_cols = 220
config.initial_rows = 60

-- Behavior ----------------------------------------------------------------

config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'

-- Keybindings --------------------------------------------------------------

config.keys = {}

-- Clipboard ----------------------------------------------------------------

if is_macos then
  -- macOS: Cmd+c/v

  table.insert(config.keys, {
    key = 'c',
    mods = 'CMD',
    action = act.CopyTo 'ClipboardAndPrimarySelection',
  })

  table.insert(config.keys, {
    key = 'v',
    mods = 'CMD',
    action = act.PasteFrom 'Clipboard',
  })

else
  -- Linux:
  -- Ctrl+c -> copy
  -- Ctrl+Shift+c -> SIGINT

  table.insert(config.keys, {
    key = 'c',
    mods = 'CTRL',
    action = act.CopyTo 'ClipboardAndPrimarySelection',
  })

  table.insert(config.keys, {
    key = 'c',
    mods = 'CTRL|SHIFT',
    action = act.SendKey {
      key = 'c',
      mods = 'CTRL',
    },
  })

  -- Ctrl+v -> paste
  -- Ctrl+Shift+v -> literal Ctrl+v

  table.insert(config.keys, {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  })

  table.insert(config.keys, {
    key = 'v',
    mods = 'CTRL|SHIFT',
    action = act.SendKey {
      key = 'v',
      mods = 'CTRL',
    },
  })
end

-- tmux workflow shortcuts --------------------------------------------------

-- Hyper-v -> vertical split
table.insert(config.keys, {
  key = 'v',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = '|',
    },
  },
})

-- Hyper-b -> horizontal split
table.insert(config.keys, {
  key = 'b',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = '-',
    },
  },
})

-- Hyper-z -> zoom pane
table.insert(config.keys, {
  key = 'z',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'z',
    },
  },
})

-- Hyper-x -> close pane
table.insert(config.keys, {
  key = 'x',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'x',
    },
  },
})

-- Hyper-n -> next tmux window
table.insert(config.keys, {
  key = 'n',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'n',
    },
  },
})

-- Hyper-p -> previous tmux window
table.insert(config.keys, {
  key = 'p',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'p',
    },
  },
})

-- Hyper-c -> create tmux window
table.insert(config.keys, {
  key = 'c',
  mods = hyper_mods,
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'c',
    },
  },
})

-- Font size ----------------------------------------------------------------

table.insert(config.keys, {
  key = '=',
  mods = leader_mod,
  action = act.IncreaseFontSize,
})

table.insert(config.keys, {
  key = '-',
  mods = leader_mod,
  action = act.DecreaseFontSize,
})

table.insert(config.keys, {
  key = '0',
  mods = leader_mod,
  action = act.ResetFontSize,
})

-- New window ---------------------------------------------------------------

table.insert(config.keys, {
  key = 'n',
  mods = leader_mod,
  action = act.SpawnWindow,
})

-- Close window/pane --------------------------------------------------------

table.insert(config.keys, {
  key = 'w',
  mods = leader_mod,
  action = act.CloseCurrentPane { confirm = true },
})

-- Mouse --------------------------------------------------------------------

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',

    action = wezterm.action_callback(function(window, pane)
      local has_selection =
        window:get_selection_text_for_pane(pane) ~= ''

      if has_selection then
        window:perform_action(
          act.CopyTo 'ClipboardAndPrimarySelection',
          pane
        )

        window:perform_action(
          act.ClearSelection,
          pane
        )
      else
        window:perform_action(
          act.PasteFrom 'Clipboard',
          pane
        )
      end
    end),
  },
}

return config
