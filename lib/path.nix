lib: {
  pathOnly = arg: if 
    builtins.isPath arg
    then arg
    else builtins.throw "this function is used strictly on paths";

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