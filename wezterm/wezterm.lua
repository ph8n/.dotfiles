local wezterm = require 'wezterm'
local act = wezterm.action
local workspace_switcher = wezterm.plugin.require 'https://github.com/MLFlexer/smart_workspace_switcher.wezterm'

local config = wezterm.config_builder()
workspace_switcher.zoxide_path = '/Users/dp/.nix-profile/bin/zoxide'

wezterm.on('update-status', function(window)
  window:set_right_status ''
end)

config.color_schemes = {
  -- Match Ghostty's mellow theme, with the locally overridden background.
  mellow = {
    foreground = '#c9c7cd',
    background = '#151515',
    cursor_bg = '#cac9dd',
    cursor_border = '#cac9dd',
    cursor_fg = '#151515',
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
  },
}

config.color_scheme = 'mellow'
config.font_size = 14.0
config.hide_mouse_cursor_when_typing = true
config.alternate_buffer_wheel_scroll_speed = 6
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_background_opacity = 1.0
config.macos_window_background_blur = 20
config.default_cursor_style = 'SteadyBlock'
config.use_fancy_tab_bar = true
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = 'NONE'
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.window_frame = {
  font = wezterm.font { family = 'Roboto', weight = 'Bold' },
  font_size = 11.5,
  active_titlebar_bg = '#151515',
  inactive_titlebar_bg = '#151515',
  active_titlebar_fg = '#c9c7cd',
  inactive_titlebar_fg = '#7f7d84',
  active_titlebar_border_bottom = '#151515',
  inactive_titlebar_border_bottom = '#151515',
  button_fg = '#9a98a0',
  button_bg = '#151515',
  button_hover_fg = '#cac9dd',
  button_hover_bg = '#1c1c1f',
}
config.colors = {
  tab_bar = {
    inactive_tab_edge = '#151515',
    active_tab = {
      bg_color = '#1c1c1f',
      fg_color = '#cac9dd',
    },
    inactive_tab = {
      bg_color = '#151515',
      fg_color = '#7f7d84',
    },
    inactive_tab_hover = {
      bg_color = '#1c1c1f',
      fg_color = '#b8b6bc',
    },
  },
}

config.keys = {
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
  { key = 'n', mods = 'CMD', action = workspace_switcher.switch_workspace() },
  {
    key = 'f',
    mods = 'CMD',
    action = act.Search 'CurrentSelectionOrEmptyString',
  },
  {
    key = ';',
    mods = 'CMD',
    action = workspace_switcher.switch_workspace(),
  },
  { key = ':', mods = 'CMD|SHIFT', action = workspace_switcher.switch_to_prev_workspace() },
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = act.PromptInputLine {
      description = 'Rename current workspace',
      action = wezterm.action_callback(function(window, _, line)
        if line and line ~= '' then
          wezterm.mux.rename_workspace(window:active_workspace(), line)
        end
      end),
    },
  },
  { key = 'y', mods = 'CMD', action = act.ActivateCopyMode },
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = 'h', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab { confirm = false } },
  { key = 'w', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab { confirm = false } },
}

return config
