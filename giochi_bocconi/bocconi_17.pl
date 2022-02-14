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

bocconi_17(VARS, ALL_DIG):-
   length(VARS, 3),
   VARS = [N, N3, N4],
   N in 1..200,
   N3 in 1..8000000,
   N4 in 1..1600000000,
	N3 #= N^3,
   N4 #= N^4,

   labeling([], VARS),
   numToList(N3, D3),
   numToList(N4, D4),
   append(D3, D4, ALL_DIG),
   all_distinct(ALL_DIG),
   subset([0,1,2,3,4,5,6,7,8,9], ALL_DIG).