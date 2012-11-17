

(*

  This module offers a way of building regular expressions
  syntactically, following more or less the GNU regexp syntax as in
  egrep. This is summarized in the table of figure~\ref{figure:regexpsyntax}.

\begin{figure}
\begin{center}
\begin{tabular}{|l|p{10cm}|}
\hline
\textsl{char} & denotes the character \textsl{char} for all non-special chars \\ 
\hline
\verb|\|\textsl{char} & denotes the character \textsl{char} for special characters \verb|.|, \verb|\|, \verb|*|, \verb|+|, \verb|?|, \verb!|!, \verb|[|, 
\verb|]|, \verb|(| and \verb|)| \\
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
\label{figure:regexpsyntax}
\end{figure}


  Moreover, the postfix operators \verb|*|, \verb|+| and \verb|?| have priority over the concatenation, itself having priority over alternation with \verb+|+


  [from_string str] builds a regexp by interpreting syntactically the
  string [str]. The syntax must follow the table above. It raises
  exception [Invalid_argument "from_string"] if the syntax is not
  correct.

*)

val from_string : string -> Regular_expr.regexp;;

