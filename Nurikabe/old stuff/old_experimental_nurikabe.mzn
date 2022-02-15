include "all_different.mzn";

int: length = 7;
array[1..length, 1..length] of 0..9: init=[|0,0,0,0,0,0,9
                                          |0,0,0,0,0,0,0
                                          |0,0,0,6,0,0,0
                                          |0,0,0,0,4,0,0
                                          |0,0,0,3,0,0,0
                                          |0,0,0,0,0,0,0
                                          |0,0,0,0,0,0,1|];

array[1..length,1..length] of var 0..9: solution/* = [|9,9,9,9,9,9,9
                                                    |0,0,0,0,0,9,9
                                                    |0,6,6,6,0,0,0
                                                    |0,6,0,0,4,4,4
                                                    |0,6,0,3,0,0,4
                                                    |0,6,0,3,3,0,0
                                                    |0,0,0,0,0,0,1|]*/;

/* MESSAGGIO:
 Non c'è il vincolo per far sì che tutti gli zeri siano continui perchè tanto non va neanche quello che siano attaccate le
 isole. Se volete provare la soluzione che funziona con questo init commentate il vincolo che chiama il predicato couple
*/

predicate adjacency(int:i1, int:j1, int:i2, int:j2) = 
  (abs(i1 - i2) + abs(j1 - j2)) == 1;
  
% Adjacent cells need to be of the same number or 0
predicate check_adj() = forall(i1,j1,i2,j2 in 1..length where adjacency(i1,j1,i2,j2) /\ solution[i1,j1] > 0)(
  (solution[i1,j1] == solution[i2,j2]) \/ (solution[i1,j1]== 0 \/ solution[i2,j2]==0)
);


% We cannot have 2X2 "black" cells
predicate not_black_squares() = forall(i, j in 1..length-1)(
  solution[i,j] + solution[i+1,j] + solution[i+1,j+1] + solution[i,j+1] > 0
);

% Number of cells for each island equal to the clue
predicate count_clues() = forall(i,j in 1..length where init[i,j] > 0)(
  let {
      var int: tmp_sum = sum(k in 1..length) 
        (count(solution[k,..], init[i,j]))
  } in tmp_sum == init [i,j]
);

% Check if all cells within an island are continuous
predicate check_islands() = 
  forall(i,j in 1..length where init[i,j] > 1)(
    forall(m,n in 1..length where solution[m,n] == init[i,j])(
      % Exists at least one adjacent cell with the same number
      exists(p,q in 1..length where solution[p,q] == solution[m,n] /\ (p != m \/ q != n))(
        adjacency(m,n,p,q)
      )
    )     
  );


% Try to avoid problems with couples
/*
Usando l'adiacenza si ha il problema che una coppia soddisfa i vincoli anche se magari l'isola è frammentata
*/
predicate couple(int:i1, int:j1, int:i2, int:j2) = 
  % If the sum of all the adjacent cells to (i1,j1),(i2,j2) is equal to 0 we have an island of 2 elements for a number > 2
  sum(p,q in 1..length where adjacency(i1,j1,p,q) \/ adjacency(i2,j2,p,q))(
    solution[p,q]
  ) == 0;
  
predicate couple_alt(int:i, int:j) = 
  % If the sum of all the adjacent cells to (i1,j1),(i2,j2) is equal to 0 we have an island of 2 elements for a number > 2
  sum(p,q in 1..length where adjacency(i,j,p,q))(
    1
  ) > 1;

constraint forall(i,j in 1..length where solution[i,j] > 1)(
%   forall(p,q in 1..length where adjacency(i,j,p,q) /\ solution[p,q] == solution[i,j])(not(couple(i,j,p,q)) \/ not(couple(i,j,p,q))));
  forall(p,q in 1..length where adjacency(i,j,p,q) /\ solution[p,q] == solution[i,j])(couple_alt(i,j) \/ couple_alt(p,q)));
  
  
constraint forall(i,j in 1..length where init[i,j]>0) (solution[i,j]=init[i,j]);
constraint not_black_squares();
constraint count_clues();
constraint check_islands();
constraint check_adj();
% If I don't put this constraint the program inserts other numbers to satify the previous constraints
constraint sum(i,j in 1..length where solution[i,j] > 0)(1) == (sum(i,j in 1..length where init[i,j]>0)(init[i,j]));

solve satisfy;
output [ show_float(4,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];