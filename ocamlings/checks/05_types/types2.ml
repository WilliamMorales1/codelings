(* HINT
   Don't mutate; copy: `let birthday p = { p with age = p.age + 1 }`. *)
let () =
  let ada = { name = "Ada"; age = 36 } in
  let older = birthday ada in
  Check.int "(birthday ada).age" older.age 37;
  Check.str "(birthday ada).name" older.name "Ada";
  Check.int "ada.age after birthday" ada.age 36
