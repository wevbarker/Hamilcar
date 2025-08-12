(*==================*)
(*  Recanonicalize  *)
(*==================*)

Recanonicalize[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=CollectTensors;
	Expr//=ScreenDollarIndices;
	Expr
];
