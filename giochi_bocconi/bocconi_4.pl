:- use_module(library(clpfd)).

% Used to get a list of digits from a number
numToList(NUM,[LIST|[]]):-
   NUM #< 10,
   LIST #= NUM,
   !.
numToList(NUM,LIST):-
   P #= NUM // 10,
   numToList(P,LIST1),
   END #= (NUM mod 10), 
   append(LIST1,[END] ,LIST).

bocconi_4(NUM):-
    NUM mod 2 #= 0,
    NUM mod 11 #= 0,
    NUM // 1000 #> 0,
    NUM // 10000 #=< 0,
    numToList(NUM, DIGITS),
    all_distinct(DIGITS),
    labeling([up], [NUM]).

