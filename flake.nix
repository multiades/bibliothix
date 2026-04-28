# SPDX-License-Identifier: AGPL-3.0-or-later

{
  description = "Auxiliary Nix function library, no nixpkgs dependency";

  # No `inputs` attribute since no dependency is present
  
  outputs = { 
    self, 
    ...
  }: import ./default.nix;
}