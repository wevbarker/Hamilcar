(*===============================*)
(*  ToHigherDerivativeCanonical  *)
(*===============================*)

ToHigherDerivativeCanonical[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=CollectTensors;
	Expr//=SymmetrizeCovDs;
	Expr//=ExpandSymCovDs;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=CollectTensors;
	(*Expr//=FullSimplification[];*)
	Expr//=(#/.CurvatureRelationsBianchi@CD)&;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=CollectTensors;
Expr];
