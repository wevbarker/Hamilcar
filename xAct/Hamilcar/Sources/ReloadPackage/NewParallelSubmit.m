(*=========================*)
(*  NewParallelSubmit  *)
(*=========================*)

NewParallelSubmit~SetAttributes~HoldAll;

NewParallelSubmit[Expr_]:=NewParallelSubmit[{},Expr];
NewParallelSubmit[{Vars___},Expr_]~Y~({Vars}~ParallelSubmit~Block[{Print=Null&,PrintTemporary=Null&},Expr]);
