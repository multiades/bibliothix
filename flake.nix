# For flake consumers
{
  description = "bibliothix, a personal Nix language library";

  inputs = {
  }; 

  outputs = { 
    self 
  }: {
    lib = import ./lib;
  };
}