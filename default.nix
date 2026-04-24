/*
No need for a flake, it is only a library of auxilliary functions.
This file is the aggregator of the modules in ./lib.
Assemble everything into a single lib attrset, self-referencing it instead of having the attribute set be a recursive one,  so modules can call each other.
Because Nix is lazy, lib is only evaluated when its attributes are actually accessed. Each module receives the whole lib and can call siblings through it.
*/
let
  lib = {
    list = builtins.import ./lib/list.nix lib;
    path = builtins.import ./lib/path.nix lib;
  };
in lib
