
# Table of Contents

1.  [./flake.nix](#org764e312)
2.  [./default.nix](#orga222f53)
3.  [./lib/](#org9458656)
    1.  [./lib/list.nix](#orgb3e7916)
    2.  [./lib/path.nix](#org41b003e)


<a id="org764e312"></a>

# ./flake.nix

    
    {
      description = "Auxiliary Nix function library, no nixpkgs dependency";
    
      # No `inputs` attribute since no dependency is present
      
      outputs = { 
        self, 
        ...
      }: import ./default.nix;
    }


<a id="orga222f53"></a>

# ./default.nix

    
    let
      lib = {
        list = builtins.import ./lib/list.nix lib;
        path = builtins.import ./lib/path.nix lib;
      };
    in
      lib


<a id="org9458656"></a>

# ./lib/

This directory contains the modules of the library.


<a id="orgb3e7916"></a>

## ./lib/list.nix

    
    lib: {
      listOnly = emptyAllowed: arg: let 
        buffer = [ # Dynamic error message, will show up in other functions which use listOnly
          "this function is used strictly on"
          (if emptyAllowed then " " else " non empty ")
          "lists"
        ];
      in if 
        builtins.isList arg && (emptyAllowed || arg != [])
        then arg
        else buffer
          |> builtins.concatStringsSep "" 
          |> builtins.throw;
    
      isMember = x: xs: builtins.any # builtins.any is a lazy, short-circuiting function
        (y: y == x)
        xs;
    
      cons = toLeft: x: xs: xs # toLeft is Boolean, deciding the end we cons on
        |> lib.list.listOnly
        |> (list: if 
          toLeft 
          then [x] ++ list
          else list ++ [x]);
    
      foldR = f2: base: xs: let 
        go = ys: if
          ys == []
          then base
          else f2 
            (builtins.head ys)
            (ys |> builtins.tail |> go);
      in xs
        |> lib.list.listOnly true
        |> go;
    
      foldR1 = f2: xs: xs
        |> lib.list.listOnly false
        |> (list: lib.list.foldR # Need to wrap a function here, otherwise builtins.tail is evalueated eagerly and its error message takes precedence over listOnly's error message when xs is an empty list
          f2
          (builtins.head list)
          (builtins.tail list));
    
      # init = xs: ...
    
      last = xs: lib.list.foldR1
        (_: b: b)
        xs;
    }


<a id="org41b003e"></a>

## ./lib/path.nix

    
    lib: {
      pathOnly = arg: if 
        builtins.isPath arg
        then arg
        else builtins.throw "this function is used strictly on paths";
    
      withPath = parentPath: baseStrs: builtins.map
        (s: parentPath + ("/" + s))
        baseStrs;
    
      pathToBasename = arg: arg
        |> lib.path.pathOnly
        |> builtins.toString
        |> (path: path 
          |> builtins.match ".*/(\\.*[^./]+)(\\.[^/]*)?" # builtins.match returns null if there's no match with the regex, or a list of capture groups
          |> builtins.head); 
    
      findFiles = { # Maybe add recursion for directories (and symlinks pointing to directories) in the future
        root, # Search within root
        filetype, 
        suffix # Terminating substring
      }: let
        validFiletypes = [ # Based on the behaviour of builtins.readDir
          "directory"
          "regular" 
          "symlink"
          "unknown"
        ];
        entries = if 
          !(builtins.pathExists root) # Guard against non existent directories
          then builtins.throw ("there is no " + builtins.toString root + " directory in the filesystem")
          else if 
            !(lib.list.isMember filetype validFiletypes) # Guard against invalid filetypes
            then builtins.throw 
              ("there is no '"
              + filetype 
              + "' filetype available, it should be one of: '"
              + builtins.concatStringsSep "', '" validFiletypes
              + "' (special filesystem entities like device files, named pipes/FIFOS, sockets)")
            else builtins.readDir root; # The keys of the returned attribute set are relative path names (of type string) from root
      in entries
        |> builtins.attrNames
        |> builtins.filter (attrName: 
          let suffixLen = builtins.stringLength suffix;
          in entries.${attrName} == filetype
          && builtins.substring
            (builtins.stringLength attrName - suffixLen)
            suffixLen
            attrName == suffix)
        |> builtins.map (attrName: 
          let temp = root + "/${attrName}";
          in {
            basename = lib.path.pathToBasename temp;
            path = temp;
          });
    }

