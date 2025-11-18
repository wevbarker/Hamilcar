(*=================*)
(*  ProjectMetric  *)
(*=================*)

ProjectMetric[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=SeparateMetric[G];
	Expr//=ScreenDollarIndices;
	Expr//=(#/.GToInverseInducedMetric)&;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
Expr];
