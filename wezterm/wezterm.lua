local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.colors = {
  foreground = '#c9c7cd',
  background = '#151515',
  cursor_bg = '#cac9dd',
  cursor_border = '#cac9dd',
  cursor_fg = '#161617',
  selection_bg = '#2a2a2d',
  selection_fg = '#c1c0d4',
  ansi = {
    '#27272a',
    '#f5a191',
    '#90b99f',
    '#e6b99d',
    '#aca1cf',
    '#e29eca',
    '#ea83a5',
    '#c1c0d4',
  },
  brights = {
    '#424246',
    '#ffae9f',
    '#9dc6ac',
    '#f0c5a9',
    '#b9aeda',
    '#ecaad6',
    '#f591b2',
    '#cac9dd',
  },
}
config.font_size = 13.0
config.hide_mouse_cursor_when_typing = true
config.alternate_buffer_wheel_scroll_speed = 2
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_background_opacity = 1.0
config.macos_window_background_blur = 20
config.default_cursor_style = 'SteadyBlock'
config.use_fancy_tab_bar = false
config.window_decorations = 'RESIZE'
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}
config.window_close_confirmation = 'NeverPrompt'

local rename_tab = act.PromptInputLine {
  description = 'Rename tab',
  action = wezterm.action_callback(function(window, _, line)
    if line then
      window:active_tab():set_title(line)
    end
  end),
}

config.keys = {
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = 'h', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 'r', mods = 'CMD', action = rename_tab },
  { key = '1', mods = 'CMD', action = act.ActivateTab(0) },
  { key = '2', mods = 'CMD', action = act.ActivateTab(1) },
  { key = '3', mods = 'CMD', action = act.ActivateTab(2) },
  { key = '4', mods = 'CMD', action = act.ActivateTab(3) },
  { key = '5', mods = 'CMD', action = act.ActivateTab(4) },
  { key = '6', mods = 'CMD', action = act.ActivateTab(5) },
  { key = '7', mods = 'CMD', action = act.ActivateTab(6) },
  { key = '8', mods = 'CMD', action = act.ActivateTab(7) },
  { key = '9', mods = 'CMD', action = act.ActivateTab(8) },
  { key = '0', mods = 'CMD', action = act.ActivateTab(9) },
}

return config
