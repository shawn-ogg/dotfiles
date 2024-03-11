-- These are the basic's for using wezterm.
-- Mux is the mutliplexes for windows etc inside of the terminal
-- Action is to perform actions on the terminal
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- These are vars to put things in later (i dont use em all yet)
local config = {}
local keys = {}
local mouse_bindings = {}
local launch_menu = {}

-- This is for newer wezterm vertions to use the config builder 
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Default config settings
-- These are the default config settins needed to use Wezterm
-- Just add this and return config and that's all the basics you need

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Oceanic Next (Gogh)'
-- This is my chosen font, we will get into installing fonts on windows later
config.font = wezterm.font('Hack Nerd Font')
config.font_size = 11
config.launch_menu = launch_menu
-- makes my cursor blink 
config.default_cursor_style = 'BlinkingBar'
config.disable_default_key_bindings = true
config.audible_bell = 'Disabled'
-- this adds the ability to use ctrl+v to paste the system clipboard 

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
	{ key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
	{ mods = "LEADER", key = "-", action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }},
	{ mods = "LEADER", key = "=", action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }},
	{ mods = 'LEADER', key = 'm', action = wezterm.action.TogglePaneZoomState },
	{ mods = 'LEADER', key = 'h', action = wezterm.action.ActivatePaneDirection "Left" },
	{ mods = 'LEADER', key = 'j', action = wezterm.action.ActivatePaneDirection "Down" },
	{ mods = 'LEADER', key = 'k', action = wezterm.action.ActivatePaneDirection "Up" },
	{ mods = 'LEADER', key = 'l', action = wezterm.action.ActivatePaneDirection "Right" },
	{ mods = "LEADER", key = "Space", action = wezterm.action.RotatePanes "Clockwise" },
	{ mods = 'LEADER', key = '0', action = wezterm.action.PaneSelect { mode = 'SwapWithActive' }},
}
config.mouse_bindings = mouse_bindings
config.hide_tab_bar_if_only_one_tab = true

-- There are mouse binding to mimc Windows Terminal and let you copy
-- To copy just highlight something and right click. Simple
mouse_bindings = {
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
 {
  event = { Down = { streak = 1, button = "Right" } },
  mods = "NONE",
  action = wezterm.action_callback(function(window, pane)
   local has_selection = window:get_selection_text_for_pane(pane) ~= ""
   if has_selection then
    window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
    window:perform_action(act.ClearSelection, pane)
   else
    window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
   end
  end),
 },
}

-- This is used to make my foreground (text, etc) brighter than my background
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.2,
  brightness = 1.5,
}

-- This is used to set an image as my background 
-- config.background = {
--     {
--         source = { File = {path = 'C:/Users/someuserboi/Pictures/Backgrounds/theone.gif', speed = 0.2}},
--  opacity = 1,
--  width = "100%",
--  hsb = {brightness = 0.5},
--     }
-- }

-- IMPORTANT: Sets WSL2 UBUNTU-22.04 as the defualt when opening Wezterm
config.default_domain = 'WSL:Ubuntu-20.04'

return config
