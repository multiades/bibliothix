A tiny Nix library of auxiliary functions with no nixpkgs dependency (self-contained).


# Lazy design

Desiring to avoid the overhead of a recursive attribute set, the library was designed to use a self-referencing attribute set so modules can call each other while remaining independently importable. Due to Nix's laziness, nothing is evaluated until actually accessed. 

The `./default.nix` file is the aggregator of the modules in the `./lib` directory.


# Usage


## Note

Some of the functions' definitions use the experimental Nix pipe operators. Make sure you enable them beforehand.


## Barebones import

Here is a minimal example of using the library as a standalone import:

    
    let 
      bibliothix = builtins.import 
        (builtins.fetchTarball {
          url = "https://github.com/multiades/bibliothix/archive/main.tar.gz";
        });
    in 
      bibliothix.list.isMember 
        "foo" 
        [ 
          "foo"
          "bar"
        ]

The aforementioned expression should evaluate to `true`.


## Flake usage

Flake consumers should have a `./flake.nix` file of the format:

    
    {
      inputs.bibliothix.url = "github:multiades/bibliothix";
    
      outputs = { 
        bibliothix,
        ... 
      }: {
        # Usage
      };
    }


# Function reference list


## List module

-   listOnly
-   isMember
-   cons
-   foldR
-   foldR1
-   last


## Path module

-   pathOnly
-   withPath
-   pathToBasename
-   findFiles


### findFiles

Useful for auto-importing all desired files in a directory without manually listing them (it even handles files with multiple types, like `./foo.tar.gz`).

It has the type signature `{ root: Path, filetype: String, suffix: String } -> List` and it locates files in a directory matching a given filetype and a filename terminating substring, returning a list of `{ basename, path }` attribute sets.

Valid filetypes (from `builtins.readDir`, since it is used):

-   "regular"
-   "directory"
-   "symlink"
-   "unknown"

Note: the function is non-recursive, it only searches the immediate contents of `root` (top-level search only).

Example usage on a directory named `modules` (in the working directory), containing two nix files, namely `networking.nix` and `locale.nix`:

    
    lib.path.findFiles {
      root = ./modules;
      filetype = "regular";
      suffix = ".nix"; # Or even "nix"
    }

That should evaluate to:

    
    [
      { 
        basename = "networking"; 
        path = /path/to/modules/networking.nix;
      }
      { 
        basename = "users";
        path = /path/to/modules/users.nix;
      }
    ]

