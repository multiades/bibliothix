# Table of Contents

1.  [Laziness](#org186aae4)
2.  [Usage](#org903c5a3)
    1.  [Warning](#orgb96beb9)
    2.  [Barebones import](#org69a0206)
    3.  [Flake input](#orgdf799ba)
3.  [Reference](#orge5da00b)
    1.  [`lib.list` module](#org1fe6e47)
    2.  [`lib.path` module](#orgab15eb5)
        1.  [`findFiles : { root: Path, filetype: String, suffix: String } -> List`](#org88ed2ae)
4.  [License](#org7de9648)

A tiny Nix library of auxiliary functions with no nixpkgs dependency (self-contained).

It may be used as a lightweight utility layer in Nix configurations, among other things.


<a id="org186aae4"></a>

# Laziness

The library uses a self-referencing attribute set instead of a recursive one, so modules can call each other while remaining independently importable. Due to Nix's laziness, nothing is evaluated until actually accessed.

The `./default.nix` file /\* is the aggregator of the modules in `./lib` directory. Each module receives the whole `./lib` as a whole and can call siblings through it.

    
    let
      lib = {
        list = import ./lib/list.nix lib;
        path = import ./lib/path.nix lib;
      };
    in
      lib


<a id="org903c5a3"></a>

# Usage


<a id="orgb96beb9"></a>

## Warning

Some of the functions' definitions use the experimental pipe operators of Nix. Make sure you enable them via adding "pipe-operators" to the experimental-features list.


<a id="org69a0206"></a>

## Barebones import

Here is a minimal example of using the library as a standalone import:

    
    let 
      bibliothix = builtins.import 
        (builtins.fetchTarball {
          url = "https://github.com/multiades/bibliothix/archive/main.tar.gz";
        });
    in 
      bibliothix.list.isMember "foo" [ "foo" "bar" ] # → true


<a id="orgdf799ba"></a>

## Flake input

For flake consumers (although the library is mostly static and this may be overkill): 

    
    {
      inputs.bibliothix.url = "github:multiades/bibliothix";
    
      # No `inputs` attribute
    
      outputs = { 
        bibliothix,
        ... 
      }: {
        # Usage
      };
    }


<a id="orge5da00b"></a>

# Reference


<a id="org1fe6e47"></a>

## `lib.list` module

`listOnly`, `isMember`, `cons`, `foldR`, `foldR1`, `last`.


<a id="orgab15eb5"></a>

## `lib.path` module

`pathOnly`, `pathToBasename`, `findFiles`.


<a id="org88ed2ae"></a>

### `findFiles : { root: Path, filetype: String, suffix: String } -> List`

Locates files in a directory matching a given filetype and a filename terminating substring. Returns a list of `{ basename, path }` attribute sets.

Valid filetypes (from `builtins.readDir`): `regular`, `directory`, `symlink`, `unknown`.

Note: the function is non-recursive, meaning it only searches the immediate contents of `root`.

Usage example on a directory named `./modules`:

    
    lib.path.findFiles {
      root = ./modules;
      filetype = "regular";
      suffix = ".nix"; # Or even "nix"
    }
    
    /*
     → [
         { 
           basename = "networking"; 
           path = /path/to/modules/networking.nix;
         }
         { 
           basename = "users";
           path = /path/to/modules/users.nix;
         }
       ]

Useful for auto-importing all desired files in a directory without manually listing them (it even handles files with multiple types, like `./foo.tar.gz`).


<a id="org7de9648"></a>

# License

AGPL-3.0-or-later. See [LICENSE](#org7de9648).

