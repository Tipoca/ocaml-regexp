
open Format;;

let do_profile = true;;

let print_list l =
  if do_profile then () else
    match l with
      | [] -> printf "[]@."
      | h::t -> 
	  printf "[ \"%s\" " h;
	  List.iter (fun s -> printf ", \"%s\"" s) t;
	  printf "]@."
;;

let tests () =

  let chiffres = Regexp_syntax.from_string "[0-9]+" in
  if do_profile then () else printf "%a@." Regular_expr.fprint chiffres;
  let a = Automata.compile chiffres in
  let (n,m) = 
    Automata.search_forward a "dsafsdf 54 53435 dfsf s4545 v4w5f4s5" 0 
  in
  if do_profile then () else printf "%d,%d@." n m;
  print_list 
    (Automata.split_strings a "dsafsdf 54 53435 dfsf s4545 v4w5f4s5");

  let ponct = Regexp_syntax.from_string "[,;:]|:=" in
  if do_profile then () else printf "%a@." Regular_expr.fprint ponct;
  let a = Automata.compile ponct in
  print_list 
    (Automata.split_strings a "dsafs;df 54: 53435 ;dfs,f s45:=45 v4w5f4s5");

  let oper = Regexp_syntax.from_string "[+\-*/()]" in
  if do_profile then () else printf "%a@." Regular_expr.fprint oper;
  let a = Automata.compile oper in
  print_list 
    (Automata.split_strings a "3+r*5/(4-7)");

  let a = Automata.compile (Regexp_syntax.from_string "[0-9]+") in
  print_list 
    (Automata.split_strings a "12+3*45");

  let a = Automata.compile (Regular_expr.char ':') in
  print_list 
    (Automata.split_delim a "marche");
  print_list 
    (Automata.split_delim a "marche:G6H3a656h6g56");
  print_list 
    (Automata.split_delim a ":marche:G6H3a656h6g56");
  print_list 
    (Automata.split_delim a "marche:G6H3a656h6g56:");

  let a = Automata.compile (Regexp_syntax.from_string ":*") in
  print_list 
    (Automata.split_delim a "marche");
  print_list 
    (Automata.split_delim a "marche:G6H3a656h6g56");
  print_list 
    (Automata.split_delim a ":marche:G6H3a656h6g56");
  print_list 
    (Automata.split_delim a "marche:G6H3a656h6g56:");

  let r = Regexp_syntax.from_string "[0-9]+|[A-Za-z][A-Za-z0-9_]*|program|var|begin|end|if|then|[,:;]|:=|[+\\-*/()]|{[^}]*}|'[^']*'" in
  let a = Automata.compile r in
  let _ = if do_profile then () else Automata.to_dot a "test.dot" in
  print_list 
    (Automata.split_strings a "program test1;

{ programme pascal naif }

var x1,x2 : real;
var b : boolean; 
    
begin
   writeln('x1 = ',x1);
   writeln('x2 = ',x2);
   writeln('norme de (x1,x2) = ',sqrt(x1*x1+x2*x2));
   b := (x1=0) and (x2=0);
   if b then writeln('vecteur nul !');
end.
")
;;

let a = Automata.compile (Regexp_syntax.from_string
			    "\(\*[^*]*\*(\*|[^*)][^*]*\*)*\)");;
let a = Automata.compile (Regexp_syntax.from_string "\"([^\"]|\\\\\")*\"");;

let _ = if do_profile then () else Automata.to_dot a "auto.dot";;


if do_profile then
  for i = 0 to 1000 do tests () done else tests ();;
