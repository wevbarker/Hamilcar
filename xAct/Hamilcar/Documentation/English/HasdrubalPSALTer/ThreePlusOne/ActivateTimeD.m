(*=================*)
(*  ActivateTimeD  *)
(*=================*)

ActivateTimeD[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=(#/.$ConvertToTimeDRules)&;
Expr];
