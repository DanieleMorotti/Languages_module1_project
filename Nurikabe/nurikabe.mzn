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
array[1..length,1..length] of 0..9: init=[|0,0,0,0,0,0,9
                                          |0,0,0,0,0,0,0
                                          |0,0,0,6,0,0,0
                                          |0,0,0,0,4,0,0
                                          |0,0,0,3,0,0,0
                                          |0,0,0,0,0,0,0
                                          |0,0,0,0,0,0,1|];
                                                      
array[1..length,1..length] of var 0..9: solution;

% The solution must have the same clues as the input
constraint forall(i,j in 1..length where init[i,j]>0) (solution[i,j]=init[i,j]);

% Island creation by checking the square around him
predicate island_path() =
  % Checking on >1 because the case with 1 doesn't need any 
  forall(i,j in 1..length where init[i,j]>=1) (             
    let {
      var int: island = sum(k,z in -(init[i,j]-1)..(init[i,j]-1) where ((i+k)>=1 /\ (i+k)<=length /\ (j+z)>=1 /\ (j+z)<=length)) 
        (solution[i+k,j+z] == init[i,j])
    } in island==(init[i,j])
  );
constraint island_path();

% Checking each island's cell has at least an adjacent cell with the same value, that is a continuous path of the entire island
predicate double_check(int: i, int: j, int: dir_ver, int: dir_hor, int: res, int: val) =
  if res == 0 then true
    else if i >= 1 /\ i <= length /\ j >= 1 /\ j <= length then 
      if solution[i,j] == val then
        double_check(i, j+dir_hor, dir_ver, dir_hor, res-1, val) \/
        double_check(i+dir_ver, j, dir_ver, dir_hor, res-1, val)
        else false
      endif
      else false
    endif
  endif;

predicate triple_horizontal_check(int: i, int: j, int: dir, int: res, int: val) =
  if res == 0 then true
    else if j >= 1 /\ j <= length then 
      if solution[i,j] == val then
        triple_horizontal_check(i, j+dir, dir, res-1, val) \/
        double_check(i-1, j, -1, dir, res-1, val) \/
        double_check(i+1, j, 1, dir, res-1, val)
        else false
      endif
      else false
    endif
  endif;

predicate triple_vertical_check(int: i, int: j, int: dir, int: res, int: val) =
  if res == 0 then true
    else if i >= 1 /\ i <= length then 
      if solution[i,j] == val then
        triple_vertical_check(i+dir, j, dir, res-1, val) \/ 
        double_check(i, j-1, dir, -1, res-1, val) \/
        double_check(i, j+1, dir, 1, res-1, val)
        else false
      endif
      else false
    endif
  endif;

predicate island_continuous() =
  forall(i,j in 1..length where init[i,j]>=1) (
    triple_horizontal_check(i, j-1, -1, init[i,j]-1, init[i,j]) \/
    triple_horizontal_check(i, j+1, 1, init[i,j]-1, init[i,j]) \/
    triple_vertical_check(i-1, j, -1, init[i,j]-1, init[i,j]) \/
    triple_vertical_check(i+1, j, 1, init[i,j]-1, init[i,j])
  );  
constraint island_continuous();

% Checking each cell of an island is surrounded by another cell of same island or by a water  
predicate check_neighborhood(int: i,int: j, var int: val) =
    (if (i-1)>=1  then solution[i-1,j] == val \/ solution[i-1,j] == 0 else true endif) /\
    (if (i+1)<=length then solution[i+1,j] == val \/ solution[i+1,j] == 0 else true endif) /\
    (if (j-1)>=1 then solution[i,j-1] == val \/ solution[i,j-1] == 0 else true endif) /\
    (if (j+1)<=length then solution[i,j+1] == val \/ solution[i,j+1] == 0 else true endif)	;

predicate island_isolated() =
  forall(i,j in 1..length where solution[i,j]>1)
    (check_neighborhood(i,j, solution[i,j]));
constraint island_isolated();	


% Avoid a water area larger than a 2x2
predicate avoid_water_squares() = 
  forall (i,j in 1..length-1 where solution[i,j]==0) (not(solution[i+1,j]=0 /\ solution[i,j+1]=0 /\ solution[i+1,j+1]=0));
constraint avoid_water_squares();


% Water must be continuous
predicate vertical_water_path(int: i, int: j, int: direction, int: u, int: v) =  
  if i >= 1 /\ i <= length then
    if i == u /\ j == v then
      true
      else if solution[i,j] == 0 then
        vertical_water_path(i+direction, j, direction, u, v)
        else false
      endif
    endif
    else false  
  endif;

predicate horizontal_water_path(int: i, int: j, int: direction, int: u, int: v) = 
  if j >= 1 /\ j <= length then
    if i == u /\ j == v then
      true
      else if solution[i,j] == 0 then
        vertical_water_path(i-1, j, -1, u, v) \/ 
        vertical_water_path(i+1, j, 1, u, v) \/
        horizontal_water_path(i, j+direction, direction, u,v)
        else false
      endif
    endif
    else false  
  endif;

predicate water_continuous() =
  forall(i,j in 1..length where solution[i,j]==0) (
    forall (u,v in 1..length where (solution[u,v]==0 /\ u != i /\ v != j))
      (
        horizontal_water_path(i, j-1, -1, u, v) \/
        horizontal_water_path(i, j+1, 1, u, v) \/
        vertical_water_path(i-1, j, -1, u, v) \/
        vertical_water_path(i+1, j, 1, u, v)
      )
  );       
% constraint water_continuous();

constraint sum(i,j in 1..length)(init[i,j] * init[i,j])==sum(i,j in 1..length)(solution[i,j]);


solve satisfy;
output [ show_float(6,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];