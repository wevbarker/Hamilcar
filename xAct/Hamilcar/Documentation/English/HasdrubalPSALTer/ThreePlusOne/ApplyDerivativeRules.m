(*========================*)
(*  ApplyDerivativeRules  *)
(*========================*)

ApplyDerivativeRules[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=(#/.$DerivativeRules)&;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
Expr];
