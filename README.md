A tiny Nix library of auxiliary functions with no nixpkgs dependency (self-contained).


# Lazy design

Aiming to avoid the overhead of a recursive attribute set, the library was designed to use a self-referencing attribute set so modules can call each other while remaining independently importable. Due to Nix's laziness, nothing is evaluated until actually accessed. 

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
      bibliothix.list.satisfies
        4
        [ 
          (n: n < 3)
          (m: m == 0)
          (k: k * 2 > 6)
        ];

The aforementioned expression should evaluate to `true`, due to `4` satisfying the last predicate in the list.


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

Enumeration of functions in each module.


## List module

-   listOnly
-   satisfies
-   foldr
-   foldr1
-   last


## Path module

-   pathOnly
-   withPath
-   pathToBasename
-   fileSearch


### fileSearch

<span class="underline">Type signature</span>

    
    fileSearch :: { 
      root     :: Path, 
      filetype :: String,
      suffix   :: String
    } -> [{ 
      basename :: String,
      path     :: Path
    }]

Valid filetypes (from `builtins.readDir`, since it is used):

-   "regular"
-   "directory"
-   "symlink"
-   "unknown"

This function locates files in a given directory matching a given filetype and a filename terminating substring, returning a list of attribute sets containing the basename and the path of each discovered file. Useful for auto-importing all desired files in a directory without manually listing them.

Note: the function is non-recursive, it only searches the immediate contents of `root` (top-level search only).

Example usage on a directory named `./bashes/`, containing two bash scripts, namely `./hello-world.sh` and `./cowsay.sh`:

    
    lib.path.fileSearch {
      root = ./bashes;
      filetype = "regular";
      suffix = ".sh"; # Or even "sh"
    }

That should evaluate to:

    
    [
      { 
        basename = "hello-world"; 
        path = /<pathTo>/bashes/hello-world.sh;
      }
      { 
        basename = "cowsay";
        path = /<pathTo>/bashes/cowsay.sh;
      }
    ]

