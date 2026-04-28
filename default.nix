# SPDX-License-Identifier: AGPL-3.0-or-later

let
  lib = {
    list = builtins.import ./lib/list.nix lib;
    path = builtins.import ./lib/path.nix lib;
  };
in
  lib
