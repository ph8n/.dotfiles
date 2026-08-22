{ config, ... }:

# Home links onto the HDD. Ubuntu owns the filesystems; Home Manager
# only owns these names.

{
  home.file = {
    code = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/data/code";
      force = true;
    };
    scratch = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/data/scratch";
      force = true;
    };
  };
}
