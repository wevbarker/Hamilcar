(*==================*)
(*  Recanonicalize  *)
(*==================*)

Recanonicalize[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=CollectTensors;
	If[!$DynamicalMetric,
		Expr//=SortCovDs;
		Expr//=(#/.RiemannCD->Zero)&;
		Expr//=(#/.RicciCD->Zero)&;
		Expr//=(#/.RicciScalarCD->Zero)&;
		Expr//=SymmetrizeCovDs;
		Expr//=ToCanonical;
		Expr//=(#/.RiemannCD->Zero)&;
		Expr//=(#/.RicciCD->Zero)&;
		Expr//=(#/.RicciScalarCD->Zero)&;
		Expr//=ExpandSymCovDs;
	];	
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=CollectTensors;
	Expr//=ScreenDollarIndices;
Expr];
