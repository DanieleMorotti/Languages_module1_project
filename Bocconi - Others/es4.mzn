int: digit = 4;
int: multiple = 11;

var int: N;
    
predicate check_difference() =
  forall (i in 1..digit, j in 1..digit where i != j) (
    let {
      var int: digit = N div pow(10, i-1) mod 10; 
      var int: diff_dig = N div pow(10, j-1) mod 10;
    } in digit mod 2 == 0 /\ digit != diff_dig);

constraint N >= pow(10, digit-1) /\ N < pow(10, digit);
constraint check_difference();

constraint N mod multiple == 0;

solve minimize N;