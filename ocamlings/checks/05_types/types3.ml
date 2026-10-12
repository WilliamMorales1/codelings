(* HINT
   Add `| Square side -> side *. side`. *)
let () =
  Check.float "area (Rect (2., 3.))" (area (Rect (2., 3.))) 6.;
  Check.float "area (Square 4.)" (area (Square 4.)) 16.;
  Check.float "area (Circle 1.)" (area (Circle 1.)) Float.pi
