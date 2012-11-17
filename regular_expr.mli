

(*

This module defines the regular expressions, and provides some simple
manipulation of them.

\subsection{The regexp datatype and its constructors}

The type of regular expressions is abstract. Regular expressions may
be built from the following constructors :

\begin{itemize}

\item [empty] is the regexp that denotes no word at all.

\item [epsilon] is the regexp that denotes the empty word.

\item [char c] returns a regexp that denotes only the single-character
word [c].

\item [chars s] returns a regexp that denotes any single-character
word belonging to set of chars [s].

\item [string str] denotes the string [str] itself.  

\item [star e] where [e] is a regexp, denotes the Kleene iteration of
[e], that is all the words made of concatenation of zero, one or more
words of [e].

\item [alt e1 e2] returns a regexp for the union of languages of [e1]
and [e2].

\item [seq e1 e2] returns a regexp for the concatenation of languages
of [e1] and [e2].

\item [opt e] returns a regexp for the set of words of [e] and the
empty word.

\item [some e] denotes all the words made of concatenation of one or
more words of [e].

\end{itemize}

*)

type regexp;;
val uniq_tag : regexp -> int;;

val empty : regexp;;
val epsilon : regexp;;
val char : char -> regexp;;
val char_interv : char -> char -> regexp;;
val string : string -> regexp;;
val star : regexp -> regexp;;
val alt : regexp -> regexp -> regexp;;
val seq : regexp -> regexp -> regexp;;
val opt : regexp -> regexp;;
val some : regexp -> regexp;;

(*

  \subsection{Simple regexp operations}


  The following three functions provide some simple operations on
  regular expressions:

  \begin{itemize}

  \item [nullable r] returns [true] if regexp [r] accepts the empty
  word.

  \item [residual r c] returns the regexp [r'] denoting the language
  of words $w$ such that [c]$w$ is in the language of [r].

  \item [firstchars r] returns the set of characters that may occur at
  the beginning of words in the language of [e].

  \end{itemize}

*)

val nullable : regexp -> bool;;
val residual : regexp -> int -> regexp ;;
val firstchars : regexp -> (int * int * regexp) list ;;

(*

  \subsection{Regexp matching by runtime interpretation of regexp}

  [match_string r s] returns true if the string [s] is in the language
  denoted by [r]. This function is by no means efficient, but it is
  enough if you just need to match once a simple regexp against a
  string.

  If you have a complicated regexp, or if you're going to match the
  same regexp repeatedly against several strings, we recommend to use
  compilation of regexp provided by module [Automata].

*)

val match_string : regexp -> string -> bool;;




(*

  pretty-printer

*)

val fprint : Format.formatter -> regexp -> unit;;
val print : regexp -> unit;;
