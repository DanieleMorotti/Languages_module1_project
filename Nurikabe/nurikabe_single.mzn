% PARAMETERS
int: length;
set of int: cells;
array[1..length, 1..length] of cells: init;     
% array[1..length, 1..length] of cells: real_sol; 

% USER DEFINED PARAMETERS
int: water_cells = length * length - all_island_cells();
int: water_limit = water_cells div 2;

% VARIABLES                                 
array[1..length,1..length] of var cells: solution;

%%% USEFUL PREDICATES AND FUNCTIONS
% Checking if a point is inside the grid of size length X length
predicate in_bounds(int: i, int: j) =
  i <= length /\ i >= 1 /\ j <= length /\ j >= 1;

% Checking if two points are k cells far from each other
predicate k_adjacency(int: distance_k, int:i, int:j, int:di, int:dj) = 
  abs(di+dj) == distance_k /\ (abs(di) == 0 \/ abs(dj) == 0) /\ in_bounds(i+di, j+dj);

% Encoding a tuple of coordinates to a single number (the opposite holds) 
function var int: encode_point(var int: i, var int: j) =
  (i - 1) * length + (j-1);
  
% Checking the surface (island or water) is continuous
predicate surface_continuous(int: i, int: j, var set of int: visited, int: u, int: v, int: res) =
  res > 0 /\ (
    (i == u /\ j == v) \/
    exists (di,dj in -1..1 where k_adjacency(1,i,j,di,dj) /\ not (encode_point(i+di, j+dj) in visited)
            /\ solution[u,v] == solution[i+di,j+dj]) (
      (i+di == u /\ j+dj == v) \/ surface_continuous(i+di, j+dj, {encode_point(i,j)} union visited, u, v, res-1) 
    )
  ); 

% The total number of islands cells
function int: all_island_cells() =
  sum (i,j in 1..length where init[i,j] > 0) (init[i,j]);
  
function var int: count_cells(int: val) =
  sum(k in 1..length) (count(solution[k,..], val));
  
  
%% ISLAND CONSTRAINTS
% Checking each cell of an island is surrounded by another cell of same island or by a water  
predicate check_neighborhood(int: i,int: j) =
  forall (di,dj in -1..1 where k_adjacency(1,i,j,di,dj)) (
    solution[i+di,j+dj] == solution[i,j] \/ solution[i+di,j+dj] == 0
  );
predicate island_isolated() =
  forall(i,j in 1..length where solution[i,j] > 1)
    (check_neighborhood(i,j));
 
       
% The number of cells for each island is equal to the clue of that island
predicate island_count_cells() = 
  forall(i,j in 1..length where init[i,j] > 0)(
    count_cells(init[i,j]) == init[i,j]
  );

% Each island must have a continuous shape
predicate island_continuous() = 
  forall(i,j in 1..length where init[i,j] > 1) (
    forall(u,v in 1..length where init[i,j] == solution[u,v] /\ (i != u \/ j != v)) (
      surface_continuous(i,j,{}, u,v, init[i,j]-1)
    )
  );
  
   
%%% WATER CONSTRAINTS
% Adding water between two cells of different island which are diagonally adjacent
predicate diagonally_adjacents() = 
  forall(i,j in 1..length where solution[i,j] > 0) (
    forall(di,dj in -1..1 where abs(di) + abs(dj) == 2 /\ in_bounds(i+di,j+dj) /\ 
            solution[i,j] != solution[i+di, j+dj] /\ solution[i+di, j+dj] > 0) (
        solution[i+di, j] == 0 /\ solution[i, j+dj] == 0
    )
  );

% Adding water between two cells of different island which are 2 cells far from the other horizontally
predicate horizontally_adjacents() =
  forall(i,j in 1..length where solution[i,j] > 0) ( 
    forall(dj in -2..2 where k_adjacency(2, i,j,0,dj) /\ solution[i,j] != solution[i, j+dj] /\ solution[i, j+dj] > 0) (
        solution[i, j+(dj div 2)] == 0
    )
  );
  
% Adding water between two cells of different island which are 2 cells far from the other vertically 
predicate vertically_adjacents() =
  forall(i,j in 1..length where solution[i,j] > 0) ( 
    forall(di in -2..2 where k_adjacency(2, i,j,di,0) /\ solution[i,j] != solution[i+di, j] /\ solution[i+di, j] > 0) (
        solution[i+(di div 2), j] == 0
    )
  );
  
% Water cannot create 2x2 cells shape
predicate water_not_squares() = 
  forall(i,j in 1..length-1)(
    solution[i,j] + solution[i+1,j] + solution[i+1,j+1] + solution[i,j+1] > 0
  );
 
% The number of water cells is the difference between all the cells and islands' ones
predicate water_count_cells() =
  count_cells(0) == water_cells;

% Water must have a continuous shape
predicate water_continuous() = 
  exists(i,j in 1..length where solution[i,j] == 0) (
    forall(u,v in 1..length where solution[u,v] == 0 /\ (i != u \/ j != v)) (
      surface_continuous(i,j,{}, u,v, water_limit-1)
    )
  );
  
  
%%% CONSTRAINTS
constraint forall(i,j in 1..length where init[i,j]>0) (solution[i,j]==init[i,j]);

constraint island_isolated();	
constraint water_continuous();

constraint water_count_cells();
constraint island_count_cells();

constraint island_continuous();
constraint water_not_squares();

constraint diagonally_adjacents();
constraint horizontally_adjacents();
constraint vertically_adjacents();

solve :: int_search(solution, first_fail, indomain_min) satisfy;
% solve satisfy;

output [ show_float(4,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];