lib: {
  pipe = arg: fs: builtins.foldl'
    (acc: f: f acc)
    arg
    fs;

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
      else lib.list.pipe buffer [
        (builtins.concatStringsSep "")
        builtins.throw
      ];

  satisfies = arg: predicates: builtins.any # builtins.any is a lazy, short-circuiting function, its second argument is expected to be a list
    (predicate: predicate arg)
    predicates;

  foldr = f2: base: xs: if # xs is expected to be a list because builtins.head and builtins.tail are applied on it
    xs == []
    then base
    else f2
      (builtins.head xs)
      (lib.list.pipe xs [
        builtins.tail
        (lib.list.foldr f2 base) # Need to reference `foldr` like this even in its recursive definition, since the `lib` attribute set is not recursive
      ]);

  foldr1 = f2: xs: lib.list.pipe xs [
    (ys: if 
      ys == []
      then builtins.throw "foldr1 expects non-null lists"
      else ys)
    (zs: lib.list.foldr
      f2
      (builtins.head zs)
      (builtins.tail zs))
  ];


  last = xs: lib.list.foldr1
    (_: b: b)
    xs;
}
