(*======================*)
(*  CollectConstraints  *)
(*======================*)

ConjugateTerm[InputExpr_,Constraint_[ConstInds___]]:=Module[{Expr=InputExpr},
	Expr//=(#/.{Constraint->DummyConstraint})&;
	Expr//=VarD[DummyConstraint[ConstInds],CD];
	Expr//=TotalTo;
	(*Expr//=ToHigherDerivativeCanonical;*)
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Constraint[ConstInds]*Expr];

CollectConstraints[InputExpr_,ConstraintsList_]:=Module[
	{Expr=0},
	(Expr+=ConjugateTerm[InputExpr,#])&/@ConstraintsList;
	(*(Expr+=(#*ToHigherDerivativeCanonical@TotalTo@(VarD[#,
		CD]@InputExpr)))&/@ConstraintsList;*)
Expr];
