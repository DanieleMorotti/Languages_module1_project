:- use_module(library(clpfd)).

% True if all the numbers in the list contain the digit D
contains([],_):-!.
contains([H|TAIL],D):-
   number_codes(H,N), 
   maplist(plus(48),X,N),    
   member(D,X),
   contains(TAIL,D).

bocconi_7(N,NUMS):-
   length(NUMS,10),
   NUMS = [N2,N3,N4,N5,N6,N7,N8,N9,N10,N11],
   N // 10 #> 0, N // 100 #< 1,
   N2#=N*2,N3#=N*3,N4#=N*4,N5#=N*5,N6#=N*6,N7#=N*7,
   N8#=N*8,N9#=N*9,N10#=N*10,N11#=N*11,
   labeling([], NUMS),
   contains(NUMS,9).


