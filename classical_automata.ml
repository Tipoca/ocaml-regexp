
(*

  Compilation of regexp into an automaton

*)

module IntMap = 
  Map.Make(struct type t = int let compare (x:int) (y:int) = compare x y end);;

module IntSet = 
  Set.Make(struct type t = int let compare (x:int) (y:int) = compare x y end);;

module CharMap = 
  Map.Make(struct type t = char let compare (x:char) (y:char) = compare x y end);;

open Regular_expr;;


(*

  \subsection{The type of automata}

  Automata considered here are deterministic.

  The states of these automata are always represented as natural
  numbers, the initial state always being 0.

  An automaton is then made of a transition table, giving for each
  state $n$ a map that maps characters to states ; and a table of
  accepting states.

*)
 

type automaton =
    {
      auto_trans : int CharMap.t array;
      auto_accept : bool array;
    }
;;

(*

  \subsection{Compilation of a regexp}

  [compile r] returns an automaton that recognizes the language of [r].

*)

let compile r =
  
  (* we have a hash table to avoid several compilation of the same regexp *)
  let hashtable = Hashtbl.create 37
		    
  (* [transtable] is the transition table to fill, and [acceptable] is
     the table of accepting states. [transtable] maps any state into a
     [CharMap.t], which itself maps characters to states. *)

  and transtable = ref IntMap.empty
  and acceptable = ref IntSet.empty
  and next_state = ref 0
  in

  (* [loop r] fills the tables for the regexp [r], and return the 
     initial state  of the resulting automaton. *)

  let rec loop r =
    
    try
      Hashtbl.find hashtable r
    with
	Not_found ->
	  (* generate a new state *)
	  let init = !next_state 
	  and next_chars = Regular_expr.firstchars r 
	  in
	  incr next_state;
	  (* fill the hash table before recursion *)
	  Hashtbl.add hashtable r init;
	  (* fill the set of acceptable states *)
	  if nullable r then acceptable := IntSet.add init !acceptable;
	  (* compute the map from chars to states for the new state *)
	  let t = 
	    CharSet.fold
	      (fun c accu ->
		 let s = loop (residual r c) in
		 CharMap.add c s accu)
	      next_chars
	      CharMap.empty
	  in
	  (* add it to the transition table *)
	  transtable := IntMap.add init t !transtable;
	  (* return the new state *)
	  init
  in 
  let _ = loop r in

  (* we then fill the arrays defining the automaton *)
  let trans = Array.create !next_state CharMap.empty 
  and accept = Array.create !next_state false 
  in
  for i=0 to pred !next_state do
    trans.(i) <- IntMap.find i !transtable;
    accept.(i) <- IntSet.mem i !acceptable
  done;
  { auto_trans = trans ; auto_accept = accept }
;;

(*

  \subsection{Execution of automata}

*)

(*

  [exec_automaton auto str pos] executes the automaton [auto] on
  string [str] starting at position [pos]. Returns the maximal
  position [p] such that the substring of [str] from positions [pos]
  (included) to [p] (excluded) is acceptable by the automaton, [-1] if
  no such position exists.

*)

let exec_automaton auto s pos =
    let state = ref 0 
    and last_accept_pos = 
      ref (if auto.auto_accept.(0) then pos else -1)
    and i = ref pos
    and l = String.length s 
    in
    try
      while !i < l do
	let m = auto.auto_trans.(!state) in
	state := CharMap.find (String.get s !i) m;
	incr i;
	if auto.auto_accept.(!state) then last_accept_pos := !i;
      done;
      !last_accept_pos;
    with
	Not_found ->
	  !last_accept_pos;
;;
  

(*

  \subsection{Searching functions}

*)

(*

  [search_forward a str pos] search in the string [str], starting at
  position [pos] a word that is in the language of automaton
  [a]. Returns a pair [(b,e)] where [b] is position of the first char
  matched, and [e] is the position following the position of the last
  char matched.

  Raises [Not_found] of no matching word is found.

  Notice: even if the automaton accepts the empty word, this function
  will never return [(b,e)] with [e=b]. In other words, this function
  always search for non-empty words in the language of automaton [a].

  Unpredictable results may occur if [pos < 0].

*)

let rec search_forward auto s pos =
  if pos >= String.length s 
  then raise Not_found
  else
    let n = exec_automaton auto s pos in
    if n > pos then pos,n else search_forward auto s (succ pos)
;;




(*

  [split_strings a s] extract from string [s] the subwords (of maximal
  size) that are in the language of [a]

*)

let split_strings auto line =
  let rec loop pos =
    try
      let b,e = search_forward auto line pos in
      let id = String.sub line b (e-b) in
      id::(loop e)
    with Not_found -> []
  in
  loop 0
;;


let split_delim auto line  =
  let rec loop pos =
    try
      let b,e = search_forward auto line pos in
      let id = String.sub line pos (b-pos) in
      id::(loop e)
    with Not_found -> 
      [String.sub line pos (String.length line - pos)]
  in
  loop 0
;;


(*

  \subsection{Output functions}

*)

(*

  [to_dot a f] exports the automaton [a] to the file [f] in DOT format.

*)

open Printf

let complement = CharSet.diff Regexp_lexer.all_chars

let intervals s =
  let rec interv = function
    | i, [] -> List.rev i
    | [], n::l -> interv ([(n,n)], l)
    | (mi,ma)::i as is, n::l -> 
	if Char.code n = succ (Char.code ma) then 
	  interv ((mi,n)::i,l) 
	else 
	  interv ((n,n)::is,l)
  in
  interv ([], CharSet.elements s)

let output_label cout s =
  let char = function
    | '"' -> "\\\""
    | '\\' -> "#92"
    | c -> 
	let n = Char.code c in
	if n > 32 && n < 127 then String.make 1 c else sprintf "#%d" n
  in
  let output_interv (mi,ma) =
    if mi = ma then 
      fprintf cout "%s " (char mi) 
    else if Char.code mi = pred (Char.code ma) then
      fprintf cout "%s %s " (char mi) (char ma)
    else
      fprintf cout "%s-%s " (char mi) (char ma)
  in
  let is = intervals s in
  let ics = intervals (complement s) in
  if List.length is < List.length ics then
    List.iter output_interv is
  else begin
    fprintf cout "[^"; List.iter output_interv ics; fprintf cout "]"
  end

let output_transitions cout i m =
  let rev_m =
    CharMap.fold 
      (fun c j rm -> 
	 let s = try IntMap.find j rm with Not_found -> CharSet.empty in
	 IntMap.add j (CharSet.add c s) rm)
      m IntMap.empty
  in
  IntMap.iter
    (fun j s ->
       fprintf cout "  %d -> %d [ label = \"" i j;
       output_label cout s;
       fprintf cout "\" ];\n")
    rev_m

let to_dot a f =
  let cout = open_out f in
  fprintf cout "digraph finite_state_machine {
  /* rankdir=LR; */
  orientation=land;
  node [shape = doublecircle];";
  Array.iteri (fun i b -> if b then fprintf cout "%d " i) a.auto_accept;
  fprintf cout ";\n  node [shape = circle];\n";
  Array.iteri (output_transitions cout) a.auto_trans;
  fprintf cout "}\n";
  close_out cout

