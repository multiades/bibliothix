{
  lib
}: {
  pathOnly = arg: if builtins.isPath arg
  then arg
  else builtins.throw "this function is used strictly on paths";

  pathToBasename = arg: arg
    |> lib.pathOnly
    |> builtins.toString
    |> (path: path 
      |> builtins.match ".*/(\\.*[^./]+)(\\.[^/]*)?" # builtins.match returns null if there's no match with the regex, or a list of capture groups
      |> builtins.head);  

  findFiles = { 
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
    entries = if # The keys of the returned attribute set are relative path names (of type string) from root
      builtins.pathExists root && # Guard against non existent directories
      lib.isMember 
        filetype 
        validFiletypes
    then builtins.readDir root
    else {};
  in entries;
}