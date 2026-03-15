local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

local function switch_to_workspace(window, pane, name)
  if not name or name == '' then
    return
  end

  window:perform_action(act.SwitchToWorkspace { name = name }, pane)
end

local function wheel_multiplier(multiplier)
  return wezterm.action_callback(function(window, pane)
    for _ = 1, multiplier do
      window:perform_action(act.ScrollByCurrentEventWheelDelta, pane)
    end
  end)
end

wezterm.on('update-right-status', function(window, _pane)
  window:set_right_status(' workspace:' .. window:active_workspace() .. ' ')
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
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false

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
  {
    key = 'n',
    mods = 'CMD',
    action = act.PromptInputLine {
      description = 'Enter name for new workspace',
      action = wezterm.action_callback(function(window, pane, line)
        switch_to_workspace(window, pane, line)
      end),
    },
  },
  {
    key = 'p',
    mods = 'CMD',
    action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
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

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    alt_screen = false,
    action = wheel_multiplier(2),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    alt_screen = false,
    action = wheel_multiplier(2),
  },
}

return config
