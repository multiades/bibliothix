# SPDX-License-Identifier: AGPL-3.0-or-later

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