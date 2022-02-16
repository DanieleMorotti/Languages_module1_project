int: multiple = 11;
int: digit = 9;

var int: N;

predicate check_num(var int: num) =
  exists (j in 1..10) (num div pow(10, j - 1) mod 10 == digit /\ N > 0);
  
predicate iterate_multiples() =
  forall(i in 1..multiple) (let {var int: num = N * i;} in check_num(num));
  
constraint N > 0;
constraint iterate_multiples();

solve satisfy;