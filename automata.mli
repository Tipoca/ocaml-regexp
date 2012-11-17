
(*

  This module provides compilation of a regexp into an automaton. It
  then provides some functions for matching and searching.

*)

(*

  \subsection{Automata, compilation}

  Automata considered here are deterministic. The type of automata is
  abstract. [compile r] returns an automaton that recognizes the
  language of [r].

*)
 

type automaton;;

val compile : Regular_expr.regexp -> automaton;;

  
(*

  \subsection{Execution of automata}

*)

(*

  [exec_automaton auto str pos] executes the automaton [auto] on
  string [str] starting at position [pos]. Returns the maximal
  position [p] such that the substring of [str] from positions [pos]
  (included) to [p] (excluded) is acceptable by the automaton, [-1] if
  no such position exists.

  Unpredictable results may occur if [pos < 0].

*)

val exec_automaton : automaton -> string -> int -> int;;
 

(*

  \subsection{Matching and searching functions}

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

val search_forward : automaton -> string -> int -> int * int;;

(*

  [split_strings a s] extract from string [s] the subwords (of maximal
  size) that are in the language of [a]. For example [split_strings
  (compile (from_string "[0-9]+")) "12+3*45"] returns
  [["12";"3";"45"]].

  [split_delim a s] splits string [s] into pieces delimited by
  [a]. For example [split_strings (compile (char ':'))
  "marche:G6H3a656h6g56:534:180:Claude Marche:/home/marche:/bin/bash"]
  returns [[ "marche" ; "G6H3a656h6g56" ; "534" ; "180" ; "Claude
  Marche" ; "/home/marche" ; "/bin/bash"]].


*)

val split_strings : automaton -> string -> string list;;
val split_delim : automaton -> string -> string list;;


(*

  [to_dot a f] exports the automaton [a] to the file [f] in DOT format.

*)

val to_dot : automaton -> string -> unit;;
