


type regexp = Regular_expr.regexp;;

let empty = Regular_expr.empty;;
let epsilon = Regular_expr.epsilon;;
let char = Regular_expr.char;;
let char_interv = Regular_expr.char_interv;;
let string = Regular_expr.string;;
let star = Regular_expr.star;;
let alt = Regular_expr.alt;;
let seq = Regular_expr.seq;;
let opt = Regular_expr.opt;;
let some = Regular_expr.some;;

let match_string = Regular_expr.match_string;;

let from_string = Regexp_syntax.from_string;;

type compiled_regexp = Automata.automaton;;

let compile = Automata.compile;;
  
let search_forward = Automata.search_forward;;

let split_strings = Automata.split_strings;;
let split_delim = Automata.split_delim;;



