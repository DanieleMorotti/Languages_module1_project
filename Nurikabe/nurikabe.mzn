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
int: length = 7;
array[1..length, 1..length] of 0..9: init=[|0,0,0,0,0,0,9
                                          |0,0,0,0,0,0,0
                                          |0,0,0,6,0,0,0
                                          |0,0,0,0,4,0,0
                                          |0,0,0,3,0,0,0
                                          |0,0,0,0,0,0,0
                                          |0,0,0,0,0,0,1|];

array[1..length,1..length] of var 0..9: solution = [|9,9,9,9,9,9,9
                                                    |0,0,0,0,0,9,9
                                                    |0,6,6,6,0,0,0
                                                    |0,6,0,0,4,4,4
                                                    |0,6,0,3,0,0,4
                                                    |0,6,0,3,3,0,0
                                                    |0,0,0,0,0,0,1|];

%%%%% ISLAND
% Island creation by checking the square around him
predicate island_equal_clues() =
  forall(i,j in 1..length where init[i,j] > 0)(
    let {
        var int: sum_island = sum(row in 1..length) 
          (count(solution[row,..], init[i,j]))
    } in sum_island == init[i,j]
  );

% Checking each cell of an island is surrounded by another cell of same island or by a water  
predicate check_neighborhood(int: i,int: j, var int: val) =
    (if (i-1)>=1  then solution[i-1,j] == val \/ solution[i-1,j] == 0 else true endif) /\
    (if (i+1)<=length then solution[i+1,j] == val \/ solution[i+1,j] == 0 else true endif) /\
    (if (j-1)>=1 then solution[i,j-1] == val \/ solution[i,j-1] == 0 else true endif) /\
    (if (j+1)<=length then solution[i,j+1] == val \/ solution[i,j+1] == 0 else true endif)	;

predicate island_isolated() =
  forall(i,j in 1..length where solution[i,j]>1)
    (check_neighborhood(i,j, solution[i,j]));

%%%%% WATER
function int: island_cells() =
  sum (i,j in 1..length where init[i,j] > 0) (init[i,j]);

predicate water_cells_number() =
  let {
        var int: sum_island = sum(row in 1..length) 
          (count(solution[row,..], 0))
    } in sum_island == length * length - island_cells();
  
% Avoid a water area larger than a 2x2
predicate avoid_water_squares() = 
  forall (i,j in 1..length-1 where solution[i,j]==0) (not(solution[i+1,j]=0 /\ solution[i,j+1]=0 /\ solution[i+1,j+1]=0));


% The solution must have the same clues as the input
constraint forall(i,j in 1..length where init[i,j]>0) (solution[i,j]=init[i,j]);
constraint island_equal_clues();
constraint island_isolated();	

constraint water_cells_number();
constraint avoid_water_squares();

solve satisfy;
output [ show_float(6,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];