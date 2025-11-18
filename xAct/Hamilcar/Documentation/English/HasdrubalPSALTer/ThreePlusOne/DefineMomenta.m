(*=================*)
(*  DefineMomenta  *)
(*=================*)

DefineMomenta[InputExpr_]:=Module[{Expr},
	Expr=MapThread[
		(#1==(VarD[#2,CD][InputExpr])//ToCanonical//ContractMetric//ScreenDollarIndices)&
	,
		{$ConjugateMomenta,
		$Velocities}
	];
Expr];
