# Assemble everything into a single lib attrset, with self-reference so modules can call each other
let lib = {
  list = import ./list.nix { inherit lib; };
};
in lib