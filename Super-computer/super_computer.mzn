/* 
	DESCRIPTION OF SUPER-COMPUTER PROBLEM
For each calculation we have the starting day and the duration (consecutive).
We have N calculation and we cannot execute more than one calculation at the
same time (no overlap). Return the max number of possible calculation.
0 < N < 100000
0 < j < 1000000 this is the starting day
0 < D < 1000 the duration

- THE PROBLEM ALLOW >= IN STARTING DAY BECAUSE IF I START IN 2 AND MY DURATION IS 3, I WORK IN 2,3,4, SO I CAN START WITH ANOTHER COMPUT. IN 5
*/


% Variables and parameters declaration
include "globals.mzn";
int: N; % n of calculation
array[1..N] of 1..1000000: starting;
array[1..N] of 1..1000: duration;

array[1..N] of var 0..1: poss;
  

% Constraints declaration
predicate basic_solution() = forall (i in 1..N, j in 1..N where i != j)(
	( 
	  poss[i]*starting[i] >= poss[j]*(starting[j] + duration[j]) xor
	  poss[i]*(starting[i] + duration[i]) <= poss[j]*starting[j]
	)
);

constraint basic_solution();
var int: res = sum(poss);
solve maximize res;

% Print the solution 
output [
  "Maximum possible computations: ", show(res),"\n"
];