lib: {
  listOnly = emptyAllowed: arg: let 
    buffer = [ # Dynamic error message, will show up in other functions which use listOnly
      "this function is used strictly on"
      (if emptyAllowed then " " else " non empty ")
      "lists"
    ];
  in 
    if 
      builtins.isList arg && (emptyAllowed || arg != [])
      then arg
      else buffer
        |> builtins.concatStringsSep "" 
        |> builtins.throw;

  isMember = x: xs: builtins.any # builtins.any is a lazy, short-circuiting function, its second argument is expected to be a list
    (y: y == x)
    xs;

  satisfies = arg: predicates: builtins.any # predicates should be a list
    (predicate: predicate arg)
    predicates;

  foldr = f2: base: xs: if # xs is expected to be a list because builtins.head and builtins.tail are applied on it
    xs == []
    then base
    else f2
      (builtins.head xs)
      (builtins.tail xs |> foldr f2 base);

  foldr1 = f2: xs: xs
    |> (ys: if 
      ys == []
      then builtins.throw "foldr1 expects non-null lists"
      else ys)
    |> (zs: lib.list.foldr
      f2
      (builtins.head zs)
      (builtins.tail zs));

  last = xs: lib.list.foldr1
    (_: b: b)
    xs;
}
