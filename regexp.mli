


(*

\subsection{The regexp datatype and its constructors}

The type of regular expressions is abstract. Regular expressions may
be built from the following constructors :

\begin{itemize}

\item [empty] is the regexp that denotes no word at all.

\item [epsilon] is the regexp that denotes the empty word.

\item [char c] returns a regexp that denotes only the single-character
word [c].

\item [char_interv a b] returns a regexp that denotes any single-character
word belonging to char interval [a,b].

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

\subsection{Syntax of regular expressions}

  This function offers a way of building regular expressions
  syntactically, following more or less the GNU regexp syntax as in
  egrep. This is summarized in the table of figure~\ref{figure:regexp}.

\begin{figure}
\begin{center}
\begin{tabular}{|l|p{10cm}|}
\hline
\textsl{char} & denotes the character \textsl{char} for all non-special chars \\ 
\hline
\verb|\|\textsl{char} & denotes the character \textsl{char} for special characters \verb|.|, \verb|\|, \verb|*|, \verb|+|, \verb|?|, \verb|[| and \verb|]| \\
\hline
\verb|.| & denotes any single-character word \\
\hline
\verb|[|\textsl{set}\verb|]| &
 denotes any single-character word belonging to \textsl{set}. Intervals may be given as in \verb|[a-z]|. \\ 
\hline
\verb|[^|\textsl{set}\verb|]| & 
 denotes any single-character word not belonging to \textsl{set}. \\
\hline
\textsl{regexp}\verb|*| &
  denotes the Kleene star of \textsl{regexp} \\
\hline
\textsl{regexp}\verb|+| &
  denotes any concatenation of one or more words of \textsl{regexp} \\
\hline
\textsl{regexp}\verb|?| &
  denotes the empty word or any word denoted by \textsl{regexp} \\
\hline
\textsl{regexp$_1$}\verb+|+\textsl{regexp$_2$} &
  denotes any words in \textsl{regexp$_1$} or in \textsl{regexp$_2$} \\
\hline
\textsl{regexp$_1$}\textsl{regexp$_2$} &
  denotes any contecatenation of a word of \textsl{regexp$_1$} and a word of \textsl{regexp$_2$} \\  
\hline
\verb|(|\textsl{regexp}\verb|)| &
  parentheses, denotes the same words as \textsl{regexp}. \\
\hline
\end{tabular}
\end{center}
\caption{Syntax of regular expressions}
\label{figure:regexp}
\end{figure}


  Moreover, the postfix operators \verb|*|, \verb|+| and \verb|?| have priority over the concatenation, itself having priority over alternation with \verb+|+


  [from_string str] builds a regexp by interpreting syntactically the
  string [str]. The syntax must follow the table above. It raises
  exception [Invalid_argument "from_string"] if the syntax is not
  correct.

*)

val from_string : string -> regexp;;



(*

  \subsection{Compilation of regular expressions}

*)
 

type compiled_regexp;;

val compile : regexp -> compiled_regexp;;
  
(*

  \subsection{Matching and searching functions}

*)

(*

  [search_forward e str pos] search in the string [str], starting at
  position [pos] a word that is in the language of [r]. Returns a pair
  [(b,e)] where [b] is position of the first char matched, and [e] is
  the position following the position of the last char matched.

  Raises [Not_found] of no matching word is found.

  Notice: even if the regular expression accepts the empty word, this
  function will never return [(b,e)] with [e=b]. In other words, this
  function always search for non-empty words in the language of [r].

  Unpredictable results may occur if [pos < 0].

*)

val search_forward : compiled_regexp -> string -> int -> int * int;;

(*

  [split_strings r s] extract from string [s] the subwords (of maximal
  size) that are in the language of [r]. For example [split_strings
  (compile (from_string "[0-9]+")) "12+3*45"] returns
  [["12";"3";"45"]].

  [split_delim a s] splits string [s] into pieces delimited by
  [r]. For example [split_strings (compile (char ':'))
  "marche:G6H3a656h6g56:534:180:Claude Marche:/home/marche:/bin/bash"]
  returns [[ "marche" ; "G6H3a656h6g56" ; "534" ; "180" ; "Claude
  Marche" ; "/home/marche" ; "/bin/bash"]].


*)

val split_strings : compiled_regexp -> string -> string list;;
val split_delim : compiled_regexp -> string -> string list;;


