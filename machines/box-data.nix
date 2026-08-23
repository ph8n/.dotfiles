{ config, ... }:

# ~/code is a normal directory on the SSD. Remote storage stays on the HDD.
# Ubuntu owns the filesystems; Home Manager only owns these names.

{
  home.file = {
    storage = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/data";
      force = true;
    };
    scratch = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/data/scratch";
      force = true;
    };
  };
}
