local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

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

-- Clipboard + basic shortcuts ---------------------------------------------

config.keys = {
  -- tmux workflow shortcuts -----------------------------------------------

-- Hyper-v -> vertical split
{
  key = 'v',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = '|',
    },
  },
},

-- Hyper-'b' -> horizontal split
{
  key = 'b',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = '-',
    },
  },
},

-- Hyper-z -> zoom pane
{
  key = 'z',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'z',
    },
  },
},

-- Hyper-x -> close pane
{
  key = 'x',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'x',
    },
  },
},

-- -- Hyper-s -> sesh popup
-- {
--   key = 's',
--   mods = 'SHIFT|CTRL|ALT|CMD',
--   action = wezterm.action.Multiple {
--     wezterm.action.SendKey {
--       key = 'a',
--       mods = 'CTRL',
--     },
--     wezterm.action.SendKey {
--       key = 's',
--     },
--   },
-- },

-- Hyper-n -> next tmux window
{
  key = 'n',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'n',
    },
  },
},

-- Hyper-p -> previous tmux window
{
  key = 'p',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'p',
    },
  },
},

-- Hyper-c -> create tmux window
{
  key = 'c',
  mods = 'SHIFT|CTRL|ALT|CMD',
  action = wezterm.action.Multiple {
    wezterm.action.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
    wezterm.action.SendKey {
      key = 'c',
    },
  },
},

  -- Copy / paste
  {
    key = 'c',
    mods = 'CMD',
    action = act.CopyTo 'ClipboardAndPrimarySelection',
  },
  {
    key = 'v',
    mods = 'CMD',
    action = act.PasteFrom 'Clipboard',
  },

  -- Font size
  {
    key = '=',
    mods = 'CMD',
    action = act.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CMD',
    action = act.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CMD',
    action = act.ResetFontSize,
  },

  -- New window
  {
    key = 'n',
    mods = 'CMD',
    action = act.SpawnWindow,
  },

  -- Close window/pane
  {
    key = 'w',
    mods = 'CMD',
    action = act.CloseCurrentPane { confirm = true },
  },
}

-- Mouse -------------------------------------------------------------------

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''

      if has_selection then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end),
  },
}

return config
