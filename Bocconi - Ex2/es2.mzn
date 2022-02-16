/*
         Ex. 2 Bocconi
The man enters in the labyrinth in the first node of the array. It needs to arrive 
to the 13-th node, considering this enumeration:
  1 2 3
4 5 6 7 8
   ... 
He can pass through each node only once and we want the maximum distance he can cross.
*/  
include "globals.mzn"; 

int: n;
int: num_edges;
int: start;
int: target;

array[1..n] of var 0..n: x;
array[1..num_edges, 1..2] of 1..n: graph;

% It is the length of the path we are considering
var int: path_length = sum(i in 1..n) (x[i] > 0);

% y is the last element which is > 0. All elements after y is 0
predicate last_not_0(array[int] of var int: x, var int: y) =
  exists(i in 1..length(x)) (
    x[i] = y /\ 
    forall(j in i+1..n) (x[j] = 0) /\ % all elements after y are 0
    forall(j in 1..i) (x[j] > 0) % all elements before y are > 0
  );

% Generate all possible paths
predicate all_paths(array[int] of var int: x, array[int, 1..2] of var int: graph) =
  forall(i in 2..length(x)) (
    x[i] = 0 \/
    (
      x[i] > 0 /\ x[i-1] > 0 /\
      % Return index set of first dimension of two-dimensional array graph
      exists(j in 1..num_edges) (
        (graph[j,1] = x[i-1] /\ graph[j,2] = x[i])
        \/
        (graph[j,1] = x[i] /\ graph[j,2] = x[i-1])
      )
    )
  );

% We can add path_length = n to see if we have a solution with that length
predicate compute_solution() = 
  alldifferent_except_0(x) /\ x[1] = start /\ 
    last_not_0(x, target) /\ all_paths(x, graph);

constraint compute_solution();

%solve :: int_search(x, first_fail, indomain, complete) maximize path_length;
solve maximize path_length;

output [
  "Path length: \(path_length) - Path cost: \((path_length-1)*10)\n x: \([x[i] | i in 1..n where fix(x[i]) > 0])\n"
];
