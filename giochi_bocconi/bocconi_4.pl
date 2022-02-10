:- use_module(library(clpfd)).


% Used to get a list of digits from a number
numToList(NUM,[LIST|[]]):-
   NUM < 10,
   LIST is NUM,
   !.
numToList(NUM,LIST):-
   P is NUM // 10,
   numToList(P,LIST1),
   END is (NUM mod 10), 
   append(LIST1,[END] ,LIST).

bocconi_4(NUM):-
    NUM mod 2 #= 0,
    NUM mod 11 #= 0,
    NUM // 1000 #> 0,
    NUM // 10000 #=< 0,
    labeling([up], [NUM]),
    numToList(NUM, DIGITS),
    all_distinct(DIGITS).
