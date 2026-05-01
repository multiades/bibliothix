{
  description = "Auxiliary Nix function library, no nixpkgs dependency";

  # No `inputs` attribute since no dependency is present
  
  outputs = { 
    self, 
    ...
  }: import ./default.nix;
}
