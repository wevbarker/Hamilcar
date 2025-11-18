(*=================================*)
(*  ConstructCanonicalHamiltonian  *)
(*=================================*)

ConstructCanonicalHamiltonian[InputExpr_]:=Module[{Expr=InputExpr},
	SymplecticPart=$Velocities.$ConjugateMomenta;
	Expr=SymplecticPart-InputExpr;
Expr];
