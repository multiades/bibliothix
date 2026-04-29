let
  lib = {
    list = builtins.import ./lib/list.nix lib;
    path = builtins.import ./lib/path.nix lib;
  };
in
  lib
