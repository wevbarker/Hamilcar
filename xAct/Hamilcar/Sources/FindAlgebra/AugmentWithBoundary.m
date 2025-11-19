(*=======================*)
(*  AugmentWithBoundary  *)
(*=======================*)

IncludeHeader@"MakeDerivativeCombinations";

AugmentWithBoundary[InputExpr_]~Y~Module[{
	BoundaryAnsatz=InputExpr,
	AugmentedAnsatz,
	BoundaryAnsatzParameters},

	BoundaryAnsatz//=(#/.{DetG[]->1/Measure[]^2})&;
	BoundaryAnsatz//=PowerExpand;
	BoundaryAnsatz//=Expand;
	BoundaryAnsatz//=(List@@#)&;
	BoundaryAnsatz//=(MakeDerivativeCombinations/@#)&;
	BoundaryAnsatz//=(#/.{Measure[]->1/Sqrt@DetG[]})&;
	BoundaryAnsatz//=Flatten;

	BoundaryAnsatzParameters=$AnsatzCoefficients~Take~Length@BoundaryAnsatz;

	AugmentedAnsatz=Times~MapThread~{BoundaryAnsatzParameters,BoundaryAnsatz};
	AugmentedAnsatz//=Flatten;
	AugmentedAnsatz//=Total;
	AugmentedAnsatz//=ToHigherDerivativeCanonical;
	AugmentedAnsatz+=InputExpr;
AugmentedAnsatz];
