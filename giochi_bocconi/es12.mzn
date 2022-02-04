var 0..(pow(10, 2) - 1): N;
var 0..(pow(10, 2) - 1): NInv;

constraint NInv = N * 4 - 3;
constraint N div 10 mod 10 == NInv mod 10 /\ N mod 10 == NInv div 10 mod 10;

solve satisfy;