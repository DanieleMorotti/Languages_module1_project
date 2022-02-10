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
array[1..length,1..length] of -1..9: init=[|-1,-1,-1,-1,-1,-1,9
                                          |-1,-1,-1,-1,-1,-1,-1
                                          |-1,-1,-1,6,-1,-1,-1
                                          |-1,-1,-1,-1,4,-1,-1
                                          |-1,-1,-1,3,-1,-1,-1
                                          |-1,-1,-1,-1,-1,-1,-1
                                          |-1,-1,-1,-1,-1,-1,1|];
                                                      
array[1..length,1..length] of var 0..max(init): solution;

%%%%% ISLAND
% Island creation by checking the square around him
predicate island_path() =
  forall(i,j in 1..length where init[i,j]>1) (             
    let {
      var int: island = sum(k,z in -(init[i,j]-1)..(init[i,j]-1) where ((i+k)>=1 /\ (i+k)<=length /\ (j+z)>=1 /\ (j+z)<=length)) 
        (solution[i+k,j+z] == init[i,j])
    } in island==(init[i,j])
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

% Checking each island's cell has at least an adjacent cell with the same value, that is a continuous path of the entire island
predicate checking_vertical_island(int: i, int: j, int: dir, int: u, int: v, int: val) =
  if u == i /\ v == j then true
    else if i >= 1 /\ i <= length then 
      if solution[i,j] == val then
        checking_vertical_island(i+dir, j, dir, u, v, val)
      endif
      else false
    endif
  endif;

predicate checking_horizontal_island(int: i, int: j, int: dir, int: u, int: v, int: val) =
  if u == i /\ v == j then true
    else if j >= 1 /\ j <= length then 
      if solution[i,j] == val then
        checking_horizontal_island(i, j+dir, dir, u, v, val) \/
        checking_vertical_island(i+1, j, 1, u, v, val) \/
        checking_vertical_island(i-1, j, -1, u, v, val)
      endif
      else false
    endif
  endif;

% Water must be continuous
predicate island_continuous() =
  forall(i,j in 1..length where init[i,j]>1) (
    forall(u,v in 1..length where (solution[u,v]==init[i,j] /\ (u != i \/ v != j))) (
       checking_horizontal_island(i, j-1, -1, u, v, init[i,j]) \/
       checking_horizontal_island(i, j+1, 1, u, v, init[i,j]) \/
       checking_vertical_island(i-1, j, -1, u, v, init[i,j]) \/
       checking_vertical_island(i+1, j, 1, u, v, init[i,j])
    )
  );   


%%%%% WATER
% Avoid a water area larger than a 2x2
predicate avoid_water_squares() = 
  forall (i,j in 1..length-1 where solution[i,j]==0) (not(solution[i+1,j]=0 /\ solution[i,j+1]=0 /\ solution[i+1,j+1]=0));

predicate checking_vertical_water(int: i, int: j, int: dir, int: u, int: v) =
  if u == i /\ v == j then true
    else if i >= 1 /\ i <= length then 
      if solution[i,j] == 0 then
        checking_vertical_water(i+dir, j, dir, u, v)
      endif
      else false
    endif
  endif;

predicate checking_horizontal_water(int: i, int: j, int: dir, int: u, int: v) =
  if u == i /\ v == j then true
    else if j >= 1 /\ j <= length then 
      if solution[i,j] == 0 then
        checking_horizontal_water(i, j+dir, dir, u, v) \/
        checking_vertical_water(i+1, j, 1, u, v) \/
        checking_vertical_water(i-1, j, -1, u, v)
      endif
      else false
    endif
  endif;

% Water must be continuous
predicate water_continuous() =
  exists(i,j in 1..length where solution[i,j]==0) (
    forall(u,v in 1..length where (solution[u,v]==0 /\ (u != i \/ v != j)) ) (
       checking_horizontal_water(i, j-1, -1, u, v) \/
       checking_horizontal_water(i, j+1, 1, u, v) \/
       checking_vertical_water(i-1, j, -1, u, v) \/
       checking_vertical_water(i+1, j, 1, u, v)
    )
  );      


% The solution must have the same clues as the input
constraint forall(i,j in 1..length) 
  (solution[i,j] >= 0);
constraint forall(i,j in 1..length where init[i,j]>0) (solution[i,j]=init[i,j]);
constraint island_path();
constraint island_isolated();	
constraint water_continuous();
constraint avoid_water_squares();
constraint sum(i,j in 1..length)(init[i,j] * init[i,j])==sum(i,j in 1..length)(solution[i,j]);
constraint island_continuous();


solve satisfy;
output [ show_float(6,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];