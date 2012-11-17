

(*


\subsection{regexp datatype and simplifying constructors}

*)

module CharSet = 
  Set.Make(struct type t = char let compare (x:char) (y:char) = compare x y end);;

type regexp =
  | Empty
  | Epsilon
  | Char of char
  | Charset of CharSet.t      (*r cardinal at least 2 *) 
  | String of string          (*r length at least 2 *)
  | Star of regexp
  | Alt of regexp_set
  | Seq of regexp * regexp
and regexp_set = regexp list (*r naive implementation of sets *)
;;

let add e l =
  if List.mem e l then l else e::l
;;

let rec union l1 l2 = 
  match l1 with
    | [] -> l2
    | e::l -> if List.mem e l2 then union l l2 else e::union l l2 
;;

let empty = Empty;;

let epsilon = Epsilon;;

let char c = Char c;;

let star e = 
  match e with
    | Empty | Epsilon -> Epsilon
    | Star _ -> e
    | _ -> Star e
;;

let alt e1 e2 =
  match e1,e2 with
    | Empty,_ -> e2
    | _,Empty -> e1
    | Alt(l1),Alt(l2) -> Alt(union l1 l2)
    | Alt(l1),_ -> Alt(add e2 l1)
    | _,Alt(l2) -> Alt(add e1 l2)
    | _ -> if e1=e2 then e1 else Alt([e1;e2])
;;

let seq e1 e2 =
  match e1,e2 with
    | Empty,_ -> Empty
    | _,Empty -> Empty
    | Epsilon,_ -> e2
    | _,Epsilon -> e1
    | _ -> Seq(e1,e2)
;;

let chars s = 
  let n = CharSet.cardinal s in
  if n=0 
  then Empty 
  else if n=1 then Char (CharSet.choose s) else Charset s;;

       
let string s = 
  if s="" 
  then 
    Epsilon 
  else 
    if String.length s = 1 then Char (String.get s 0) else String s;;

(*

\subsection{extended regexp}

*)




let some e = (seq e (star e));;

let opt e = (alt e epsilon);;

(*

  \subsection{Regexp match by run-time interpretation of regexp}

*)

let rec nullable r =
  match r with 
    | Empty -> false
    | Epsilon ->  true
    | Char _ -> false
    | Charset _ -> false
    | String _ -> false  (*r cannot be [""] *)
    | Star e -> true
    | Alt(l) -> List.exists nullable l
    | Seq(e1,e2) -> nullable e1 && nullable e2
;;

let rec residual r c =
  match r with
    | Empty -> Empty
    | Epsilon ->  Empty
    | Char a -> if a=c then Epsilon else Empty
    | Charset s -> if CharSet.mem c s then Epsilon else Empty
    | String s -> (*r [s] cannot be [""] *)
	if c=String.get s 0 
	then string (String.sub s 1 (pred (String.length s)))
	else Empty
    | Star e -> seq (residual e c) r
    | Alt(l) -> 
	List.fold_right
	  (fun e accu -> alt (residual e c) accu)
	  l
	  Empty
    | Seq(e1,e2) -> 
	if nullable(e1) 
	then alt (seq (residual e1 c) e2) (residual e2 c) 
	else seq (residual e1 c) e2
;;

let match_string r s =
  let e = ref r in
  for i=0 to pred (String.length s) do
    e := residual !e (String.get s i)
  done;
  nullable !e
;;

(*

  [firstchars r] returns the set of characters that may start a word
  in the language of [r]

*)

let rec firstchars r =
  match r with
    | Empty -> CharSet.empty
    | Epsilon ->  CharSet.empty
    | Char a -> CharSet.singleton a
    | Charset s -> s
    | String s -> CharSet.singleton (String.get s 0)
    | Star e -> firstchars e
    | Alt(l) -> 
	List.fold_right
	  (fun e accu ->
	     CharSet.union (firstchars e) accu)
	  l
	  CharSet.empty
    | Seq(e1,e2) -> 
	if nullable e1
	then CharSet.union (firstchars e1) (firstchars e2)
	else firstchars e1
;;

(*i

let rec to_string r =
  match r with 
    | Empty -> "(empty)"
    | Epsilon ->  "epsilon"
    | Char c -> String.make 1 c
    | Charset s -> "(charset)"
    | String s -> s
    | Star e -> "("^(to_string e)^")*"
    | Alt(l) -> failwith "not implem" (*  "("^(to_string e1)^"|"^(to_string e2)^")" *)
    | Seq(e1,e2) -> "("^(to_string e1)^"."^(to_string e2)^")"
;;

*)
