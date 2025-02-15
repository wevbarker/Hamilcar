(*==================*)
(*  Recanonicalise  *)
(*==================*)

Recanonicalise@InputExpr_:=Module[{Expr=InputExpr},
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
Expr];
