int: digits = 4;
var int: N;

function var int: digit(int: i) =
  N div pow(10, i - 1) mod 10;

function var int: removezero(int: i) =
  if digit(i) == 0 then (N div pow(10, i) * pow(10, i - 1) + (N mod pow(10, i-1)))
    else removezero(i+1) endif;
  
constraint N >= pow(10, digits - 1) /\ N < pow(10, digits);
constraint exists(i in 1..digits)(digit(i) == 0);
constraint removezero(1) * 9 == N;
solve minimize N;

output [show(N)]