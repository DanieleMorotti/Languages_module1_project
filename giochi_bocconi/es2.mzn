include "globals.mzn";

array[1..4, 1..5] of 0..1: adj_mat;
array[1..30] of var 0..30: path;
solve satisfy;
constraint exists_path(1,13);
  
adj_mat = [|
    0, 1, 1, 1, 0|
    1, 1, 1, 1, 1|
    1, 1, 1, 1, 1|
    0, 1, 1, 1, 0|];

constraint alldifferent_except_0(path);

predicate exists_path_length(int: s, int: t, int: len) = 
          path[1]=s /\ path[len]=t /\ forall(i in len+1..30)(path[i]=0) /\          
          forall(i in 1..len-1)( adj_mat[path[i],path[i+1]]=1);
          
predicate exists_path(int: s, int: t) = forall(len in 2..30)(exists_path_length(s,t,len));

output ["Path: " ++ show(path)];