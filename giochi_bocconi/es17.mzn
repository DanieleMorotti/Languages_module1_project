set of int: match = 0..9;
int: digit_limit = card(match);

var int: N;
var int: N1 = pow(N, 3);
var int: N2 = pow(N, 4);

constraint N > 0;
% Uncomment to relax the problem
% constraint int2float(N) < sqrt(sqrt(2147483647)); %2^31

function var int: digits(var int: num) =
  let {
    var 0..digit_limit: power;
    constraint num >= pow(10, power-1) /\ num < pow(10, power);
  } in power;

% Comment to relax the problem
% N1 and N2 must be lower than the cardinality of the set MATCH, 
% because the concatenation of N1 and N2 is a permutation of the set MATCH.
constraint digit_limit == digits(N1) + digits(N2);

predicate check_occurence(int: i, var int: num) = 
  exists (j in 1..digit_limit) 
    (i == (num div pow(10, j-1) mod 10) /\ (num div pow(10, j-1) > 0));
        
% If we want to relax the constraint we can use the \/
constraint forall (i in match)
  (check_occurence(i, N1) xor check_occurence(i, N2));
    
solve minimize N;
output [ show(N1) ++ " " ++ show(N2) ++ " " ++ show(N)] ;