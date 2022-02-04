/*
  PROBLEM CONSTRAINTS
- Each island has a different number and within an island we cannot have different numbers.
- The number of cells in each island is equal to the value of the clue.
- Clues go from 1 to 9.
- All islands are isolated from each other horizontally and vertically (not diagonally).
- There cannot be water areas of 2X2 or larger.
- When completed, all water cells form a continuous shape (again, diagonals do not count).
- Each given grid has a unique solution.
*/

int: length = 6;

array[1..length,1..length] of int: init=[|0,0,0,0,0,0|
                                            0,1,0,0,0,0|
                                            5,0,3,0,0,0|
                                            0,0,0,0,0,0|
                                            0,0,2,0,0,6|
                                            0,0,0,0,0,0|];
                                          
array[1..length,1..length] of var 0..1: solution;  

% BOTH RULES CAN BE REMOVED BY INITIALIZING SOLUTION WITH INIT, THEREFORE SOLUTION WON'T BE ONLY ZERO/UNO
%Where there is a number > 0, put 1(white) in the solution
constraint forall(i, j in 1..length where init[i,j]>0) (solution[i,j]=1);
%In the solution all cells must contains 0 or 1
constraint forall(i in 1..length) (forall (j in 1..length) (solution[i,j]=1 \/ solution[i,j]=0));

% Avoid a black area larger than a 2x2
predicate avoid_black_squares() = 
  forall (i,j in 1..length-1 where solution[i,j]=0) (not(solution[i+1,j]=0 /\ solution[i,j+1]=0 /\ solution[i+1,j+1]=0));

% Island creation by checking the square around him
predicate island_path() = 
  forall(i,j in 1..length where init[i,j]>1) ( % >1 because the case with 1 is satisfied with the previous constraint               
    let {
      var int: island = sum(k,z in -(init[i,j]-1)..(init[i,j]-1) where ((i-k)>=1 /\ (i-k)<=length /\ (j-z)>=1 /\ (j-z)<=length)) 
        (solution[i-k,j-z])
    } in island>=(init[i,j])
  );


%A cell can be white iff another near cell (not near by diagonals) it's white, border excluded
constraint forall(i,j in 1..length where solution[i,j]=1 /\ i!=1 /\ i!=length /\ j!=1 /\ j!=length) 
  (solution[i-1,j]=1 \/ solution[i,j+1]=1 \/ solution[i+1,j]=1 \/ solution[i,j-1]=1);

%A cell can be white iff another near cell (not near by diagonals) it's white, conditions for border, corners exluded
constraint forall(i,j in 1..length where solution[i,j]=1 /\ i=1 /\ j!=1 /\ j!=length) (solution[i,j+1]=1 \/ solution[i+1,j]=1 \/ solution[i,j-1]=1);
constraint forall(i,j in 1..length where solution[i,j]=1 /\ i=length /\ j!=1 /\ j!=length) (solution[i-1,j]=1 \/ solution[i,j+1]=1 \/ solution[i,j-1]=1);
constraint forall(i,j in 1..length where solution[i,j]=1 /\ j=1 /\ i!=1 /\ i!=length) (solution[i-1,j]=1 \/ solution[i,j+1]=1 \/ solution[i+1,j]=1);
constraint forall(i,j in 1..length where solution[i,j]=1 /\ j=length /\ i!=1 /\ i!=length) (solution[i-1,j]=1 \/ solution[i+1,j]=1 \/ solution[i,j-1]=1);

%A cell can be white iff another near cell (not near by diagonals) it's white, conditions for corners
constraint forall(i,j in 1..length where solution[i,j]=1 /\ i=1 /\ j=1) (solution[i,j+1]=1 \/ solution[i+1,j]=1);
constraint forall(i,j in 1..length where solution[i,j]=1 /\ i=length /\ j=1) (solution[i-1,j]=1 \/ solution[i,j+1]=1);
constraint forall(i,j in 1..length where solution[i,j]=1 /\ j=length /\ i=1) (solution[i,j-1]=1 \/ solution[i+1,j]=1);
constraint forall(i,j in 1..length where solution[i,j]=1 /\ j=length /\ i=length) (solution[i-1,j]=1 \/ solution[i,j-1]=1);

constraint avoid_black_squares();
constraint island_path();

%TODO idee per dire che le caselle nere devono essere tutte collegate? Ho provato con i stessi vincoli che ho messo per le caselle biance, ovvero che ogni casella ne deve avere una delle stesso colore sopra, sotto, a destra o a sinistra, ma non funziona per le caselle nere (per quelle bianche credo sia ok)
/*constraint forall(i in 1..length) (forall (j in 1..length where solution[i,j]=0) (forall(k in 1..length) (forall (z in 1..length where i!=k /\ j!=z /\ solution[k,z]=0) (
                    
                        
                      
                    
                    )));*/

%TODO non so se quanto dico qua è effettivamente vero o non serve per i vincoli di prima: Dato che ogni isola deve essere isolata dalle altre ho pensato che potremmo codificare il bianco non con 1 come è ora, ma con un numero diverso per ogni isola, così poi basta controllare che ogni cella che non è bianca abbia sopra, sotto a destra e a sinistra o lo stesso numero oppure 0 (cella nera). Il problema è che (credo) non si possa usare il numero del clue, cioè, se in un quadratino ho 6 non posso usare il 6 per la sua isola perché se poi ho un'altra isola vicina sempre con il 6 le due si portrebbero fondere e non va bene




solve satisfy;
output [ show_float(6,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];