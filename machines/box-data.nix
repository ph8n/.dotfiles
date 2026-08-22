{ config, ... }:

# ~/code is a normal directory on the SSD. ~/scratch stays on the HDD.
# Ubuntu owns the filesystems; Home Manager only owns these names.

{
  home.file = {
    scratch = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/data/scratch";
      force = true;
    };
  };
}
