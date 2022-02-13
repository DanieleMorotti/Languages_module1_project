include "all_different.mzn";

int: length = 7;
array[1..length, 1..length] of 0..9: init=[|0,0,0,0,0,0,9
                                          |0,0,0,0,0,0,0
                                          |0,0,0,6,0,0,0
                                          |0,0,0,0,0,4,0
                                          |0,0,0,3,0,0,0
                                          |0,0,0,0,0,0,0
                                          |0,0,0,0,0,0,1|];

% array[1..length,1..length] of var 0..9: solution = [|9,9,9,9,9,9,9
%                                                     |0,0,0,0,0,9,9
%                                                     |0,6,6,6,0,0,0
%                                                     |0,6,0,0,4,4,4
%                                                     |0,6,0,3,0,0,4
%                                                     |0,6,0,3,3,0,0
%                                                     |0,0,0,0,0,0,1|];
array[1..length,1..length] of var 0..9: solution;

predicate in_bounds(int: i, int: j) =
  i <= length /\ i >= 1 /\ j <= length /\ j >= 1;

predicate k_adjacency(int: distance_k, int:i, int:j, int:di, int:dj) = 
  abs(di+dj) == distance_k /\ (abs(di) == 0 \/ abs(dj) == 0) /\ in_bounds(i+di, j+dj);

predicate adjacency(int:i1, int:j1, int:i2, int:j2) = 
  (abs(i1 - i2) + abs(j1 - j2)) == 1;  
  
%% ISLAND FUNCTIONS   
% Checking each cell of an island is surrounded by another cell of same island or by a water  
predicate check_neighborhood(int: i,int: j) =
  forall (di,dj in -1..1 where k_adjacency(1,i,j,di,dj)) (
    solution[i+di,j+dj] == solution[i,j] \/ solution[i+di,j+dj] == 0
  );

predicate island_isolated() =
  forall(i,j in 1..length where solution[i,j]>1)
    (check_neighborhood(i,j));
    
% Number of cells for each island equal to the clue
predicate island_count_cells() = 
  forall(i,j in 1..length where init[i,j] > 0)(
    let {
        var int: island_sum = sum(k in 1..length) 
          (count(solution[k,..], init[i,j]))
    } in island_sum == init[i,j]
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
%%% WATER FUNCTIONS
% Water cells between diagonally different island cells
predicate diagonally_adjacents() = 
  forall(i,j in 1..length where solution[i,j] > 0) (
    forall(di,dj in -1..1 where abs(di) + abs(dj) == 2 /\ in_bounds(i+di,j+dj) /\ solution[i,j] != solution[i+di, j+dj] /\ solution[i+di, j+dj] > 0) (
        solution[i+di, j] == 0 /\ solution[i, j+dj] == 0
    )
  );

% Water cells between horizontally adjacent different island cells
predicate horizontally_adjacents() =
  forall(i,j in 1..length where solution[i,j] > 0) ( 
    forall(dj in -2..2 where k_adjacency(2, i,j,0,dj) /\ solution[i,j] != solution[i, j+dj] /\ solution[i, j+dj] > 0) (
        solution[i, j+(dj div 2)] == 0
    )
  );
  
% Water cells between vertically adjacent different island cells
predicate vertically_adjacents() =
  forall(i,j in 1..length where solution[i,j] > 0) ( 
    forall(di in -2..2 where k_adjacency(2, i,j,di,0) /\ solution[i,j] != solution[i+di, j] /\ solution[i+di, j] > 0) (
        solution[i+(di div 2), j] == 0
    )
  );
  
% We cannot have 2X2 water cells
predicate water_not_squares() = 
  forall(i,j in 1..length-1)(
    solution[i,j] + solution[i+1,j] + solution[i+1,j+1] + solution[i,j+1] > 0
  );
 
% Counting island cells
function int: all_island_cells() =
  sum (i,j in 1..length where init[i,j] > 0) (init[i,j]);

% The number of water cells is the difference between all the cells and the island ones
predicate water_cells_number() =
  let {
        var int: sum_island = sum(row in 1..length) 
          (count(solution[row,..], 0))
    } in sum_island == length * length - all_island_cells();




predicate island_continuous_a(int: i, var int: j, var int: u, var int: v, var int: val) =
    (i=u /\ (v=j-1 \/ v = j+1)) \/ (j=v /\ (u=i-1 \/ u=i+1)) \/
    if j-1>0 then if solution[i,j-1]=val then island_continuous_a(i,j-1,u,v,val) else false endif else false endif \/
    if i+1<=length then if solution[i+1,j]=val then island_continuous_a(i+1,j,u,v,val) else false endif else false endif; 
 
predicate island_continuous_b(int: i, var int: j, var int: u, var int: v, var int: val) =
    (i=u /\ (v=j-1 \/ v = j+1)) \/ (j=v /\ (u=i-1 \/ u=i+1)) \/
    if i-1>0 then if solution[i-1,j]=val then island_continuous_b(i-1,j,u,v,val) else false endif else false endif \/
    if j+1<=length then if solution[i,j+1]=val then island_continuous_b(i,j+1,u,v,val) else false endif else false endif;          
    
%bottom, right    
predicate island_continuous_c(int: i, var int: j, var int: u, var int: v, var int: val) =
    (i=u /\ (v=j-1 \/ v = j+1)) \/ (j=v /\ (u=i-1 \/ u=i+1)) \/
    if j+1<=length then if solution[i,j+1]=val then island_continuous_c(i,j+1,u,v,val) else false endif else false endif \/
    if i+1<=length then if solution[i+1,j]=val then island_continuous_c(i+1,j,u,v,val) else false endif else false endif; 

%top, left 
predicate island_continuous_d(int: i, var int: j, var int: u, var int: v, var int: val) =
    (i=u /\ (v=j-1 \/ v = j+1)) \/ (j=v /\ (u=i-1 \/ u=i+1)) \/
    if i-1>0 then if solution[i-1,j]=val then island_continuous_d(i-1,j,u,v,val) else false endif else false endif \/
    if j-1>0 then if solution[i,j-1]=val then island_continuous_d(i,j-1,u,v,val) else false endif else false endif;  
    
    
    

%%% CONSTRAINTS
constraint forall(i,j in 1..length where init[i,j]>0) (solution[i,j]=init[i,j]);
constraint forall(i,j,u,v in 1..length where solution[i,j]>1 /\ (solution[u,v]==solution[i,j] /\ (u != i \/ v != j))) (island_continuous_a(i,j,u,v,solution[i,j]) \/ island_continuous_b(i,j,u,v,solution[i,j]) \/ island_continuous_c(i,j,u,v,solution[i,j]) \/ island_continuous_d(i,j,u,v,solution[i,j]));
constraint island_isolated();	
constraint island_count_cells();
constraint check_islands();

constraint diagonally_adjacents();
constraint horizontally_adjacents();
constraint vertically_adjacents();
constraint water_not_squares();
constraint water_cells_number();

%%% Lasciate ogne speranza, voi ch’intrate
predicate couple(int:i, int:j) = 
  % If the sum of all the adjacent cells to (i1,j1),(i2,j2) is equal to 0 we have an island of 2 elements for a number > 2
  sum(p,q in 1..length where adjacency(i,j,p,q))(
    1
  ) > 1;

constraint forall(i,j in 1..length where solution[i,j] > 1)(
%   forall(p,q in 1..length where adjacency(i,j,p,q) /\ solution[p,q] == solution[i,j])(not(couple(i,j,p,q)) \/ not(couple(i,j,p,q))));
  forall(p,q in 1..length where adjacency(i,j,p,q) /\ solution[p,q] == solution[i,j])(couple(i,j) \/ couple(p,q)));

solve satisfy;

output [ show_float(4,0,solution[i,j]) ++ 
         if j == length then "\n\n" else " " endif |
         i in 1..length, j in 1..length
         ];