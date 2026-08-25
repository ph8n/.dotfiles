_:

{
  system = {
    primaryUser = "dp";

    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };

      dock = {
        autohide = true;
        show-recents = false;
      };

      trackpad.Clicking = true;
    };
  };

  users.users.dp.home = "/Users/dp";

  # Match Hashimoto's approach: nix-darwin declares selected applications,
  # while an existing Homebrew installation owns their delivery.
  homebrew = {
    enable = true;
    casks = [
      "aldente"
      "alfred"
      "bartender"
      "betterdisplay"
      "ghostty"
      "karabiner-elements"
      "keymapp"
      "openlogi"
      "tailscale-app"
    ];
  };
}
