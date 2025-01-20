(*========*)
(*  Test  *)
(*========*)

<<xAct`xPlain`;
Title@"Hamelin";
Comment@"Von einem Pfeiffer verfürt und verloren.";
Code[
	<<xAct`Hamelin`;
];

Comment@"Here is the metric tensor.";
Expr=G[-a,-b];
DisplayExpression@Expr;

Comment@"The parallel part of the fermionic vector.";
DefCanonicalField[A[-m],FieldSymbol->"\[ScriptCapitalZ]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(Z\)]\)"];
A[-m]//DisplayExpression;
Comment@"Momentum conjugate to parallel part of the fermionic vector.";
ConjugateMomentumA[m]//DisplayExpression;
Comment@"The perpendicular part of the fermionic vector.";
DefCanonicalField[APerp[],FieldSymbol->"\[ScriptCapitalZ]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(Z\)]\)"];
APerp[]//DisplayExpression;
Comment@"Momentum conjugate to the perpendicular part of the fermionic vector.";
ConjugateMomentumAPerp[]//DisplayExpression;

Comment@"The parallel part of the axial torsion.";
DefCanonicalField[B[-m],FieldSymbol->"\[ScriptCapitalT]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(T\)]\)"];
B[-m]//DisplayExpression;
Comment@"Momentum conjugate to parallel part of the axial torsion.";
ConjugateMomentumB[m]//DisplayExpression;
Comment@"The perpendicular part of the axial torsion.";
DefCanonicalField[BPerp[],FieldSymbol->"\[ScriptCapitalT]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(T\)]\)"];
BPerp[]//DisplayExpression;
Comment@"Momentum conjugate to the perpendicular part of the axial torsion.";
ConjugateMomentumBPerp[]//DisplayExpression;

Comment@"The coupling constant.";
DefConstantSymbol[Coupling,PrintAs->"\[ScriptG]"];
Comment@"Define the potential function.";
DefScalarFunction[V,PrintAs->"\[ScriptCapitalV]"];

Comment@"Now we want to try using the PB.";

(*
Expr=PoissonBracket[A[u]+CD[-q]@ConjugateMomentumA[p]*CD[q]@CD[u]@ConjugateMomentumA[-p],A[a]*CD[-v]@A[-a]+ConjugateMomentumA[-v]];
DisplayExpression@Expr;
*)

HamiltonianDensity=(1/4)*ConjugateMomentumAPerp[]^2-ConjugateMomentumAPerp[]*CD[-m]@A[m]+V[APerp[]^2-A[-m]*A[m]];

Comment@"Here is the secondary.";

Code[HamiltonianDensity,
	Expr=PoissonBracket[ConjugateMomentumA[-m],HamiltonianDensity];
];
DisplayExpression@Expr;
Expr=Expr/.{ConjugateMomentumA->Zero};
Expr//=VarD[SmearingLeft[a],CD];
Expr=Expr/.{SmearingRight[]->1};
Expr//=ToCanonical;
Expr//=ContractMetric;
Expr//=ScreenDollarIndices;
DisplayExpression@Expr;

Comment@"Here is the bracket.";

Expr=PoissonBracket[ConjugateMomentumA[-m],Expr];
DisplayExpression@Expr;
Expr=Expr/.{ConjugateMomentumA->Zero};
(*
Expr//=VarD[SmearingLeft[a],CD];
Expr=Expr/.{SmearingRight[]->1};
*)
Expr//=ToCanonical;
Expr//=ContractMetric;
Expr//=ScreenDollarIndices;
DisplayExpression@Expr;

Quit[];

(*========================================*)
(*  Things less certain below this line!  *)
(*========================================*)

MakeInert[#]&/@{A[-m],AMomentum[m],APerp[],APerpMomentum[],B[-m],BMomentum[m],BPerp[],BPerpMomentum[]};

Get@FileNameJoin@{$ThisDirectory,"HamiltonianAnalysis","HamiltonianDensity.m"};

Comment@"Now we want to have a go at computing some Poisson brackets.";

Expr=PoissonBracket[AMomentum[q],HamiltonianDensity];
DisplayExpression@Expr;

Expr=PoissonBracket[Expr,AMomentum[p]];
DisplayExpression@Expr;

Quit[];

Comment@"Define something to skew things.";
DefConstantSymbol[CouplingS,PrintAs->"\[ScriptG]*"];

Comment@"Now we define the Hamiltonian.";
HamiltonianDensity=(
	Dagger@PhiMomentum[]*PhiMomentum[]
	-(1/2)*AMomentum[-m]*AMomentum[m]
	+I*APerp[]*(CouplingS*PhiMomentum[]*Phi[]-Coupling*Dagger@PhiMomentum[]*Dagger@Phi[])
	+AMomentum[-m]*CD[m]@APerp[]
	+(1/2)*CD[-m]@A[-n]*CD[m]@A[n]
	-(1/2)*CD[-m]@A[-n]*CD[n]@A[m]
	-CD[-m]@(Dagger@Phi[])*CD[m]@Phi[]
	-I*A[-m]*(Coupling*Dagger@Phi[]*CD[m]@Phi[]-CouplingS*Phi[]*CD[m]@(Dagger@Phi[]))
	-CouplingS*Coupling*A[-m]*A[m]*Dagger@Phi[]*Phi[]
	(*+V[Dagger@Phi[]*Phi[]]*)
);
DisplayExpression@HamiltonianDensity;

Comment@"Now we want to have a go at computing some Poisson brackets.";

Expr=PoissonBracket[Phi[],HamiltonianDensity];
DisplayExpression@Expr;
Expr=PoissonBracket[Dagger@Phi[],HamiltonianDensity];
DisplayExpression@Expr;

TidyExpr[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=ToCanonical;
	Expr//=SortCovDs;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=Simplify;	
Expr];


DefConstantSymbol[PT];
ARule=MakeRule[{A[-m],PT*A[-m]},MetricOn->All,ContractMetrics->True]~Join~MakeRule[{AMomentum[-m],PT*AMomentum[-m]},MetricOn->All,ContractMetrics->True];

ToOrder[InputExpr_,Ord_]:=Module[{Expr=InputExpr},
	Expr=Expr/.{Phi[]->PT*Phi[],
		PhiMomentum[]->PT*PhiMomentum[],
		Dagger@Phi[]->PT*Dagger@Phi[],
		Dagger@PhiMomentum[]->PT*Dagger@PhiMomentum[],
		APerp[]->PT*APerp[],
		APerpMomentum[]->PT*APerpMomentum[]};	
	Expr=Expr/.ARule;
	Expr=Series[Expr,{PT,0,Ord}];
	Expr//=Normal;
	Expr=Expr/.{PT->1};
	Expr//=TidyExpr;
Expr];

Comment@"Here is the primary constraint.";
PrimaryConstraint=APerpMomentum[];
DisplayExpression[PrimaryConstraint];

Comment@"Here is a Hamiltonian multiplier to accompany the primary.";
DefTensor[MulAPerpMomentum[],M3,PrintAs->"\!\(\*SuperscriptBox[\(\[ScriptU]\),\(\[UpTee]\)]\)"];
Expr=MulAPerpMomentum[];
DisplayExpression[Expr];

Comment@"Here is the secondary constraint.";
SecondaryConstraint=PoissonBracket[PrimaryConstraint,HamiltonianDensity];
SecondaryConstraint//=TidyExpr;
DisplayExpression[SecondaryConstraint];

Comment@"Here is the tertiary constraint.";
TertiaryConstraint=PoissonBracket[SecondaryConstraint,HamiltonianDensity];
TertiaryConstraint//=TidyExpr;
TertiaryConstraint=ToOrder[TertiaryConstraint,20];
DisplayExpression[TertiaryConstraint];

Comment@"Commutator of the tertiary with the primary.";
TertiaryPrimaryCommutator=PoissonBracket[TertiaryConstraint,PrimaryConstraint];
TertiaryPrimaryCommutator//=TidyExpr;
TertiaryPrimaryCommutator=ToOrder[TertiaryPrimaryCommutator,20];
DisplayExpression[TertiaryPrimaryCommutator];

Comment@"Commutator of the tertiary with the secondary.";
TertiarySecondaryCommutator=PoissonBracket[TertiaryConstraint,SecondaryConstraint];
TertiarySecondaryCommutator//=TidyExpr;
TertiarySecondaryCommutator=ToOrder[TertiarySecondaryCommutator,20];
DisplayExpression[TertiarySecondaryCommutator];

Comment@"Quaternary constraint.";
QuaternaryConstraint=PoissonBracket[TertiaryConstraint,HamiltonianDensity];
QuaternaryConstraint//=TidyExpr;
QuaternaryConstraint=ToOrder[QuaternaryConstraint,20];
DisplayExpression[QuaternaryConstraint];

Comment@"Commutator of the quaternary with the primary.";
QuaternaryPrimaryCommutator=PoissonBracket[QuaternaryConstraint,PrimaryConstraint*MulAPerpMomentum[]];
QuaternaryPrimaryCommutator//=TidyExpr;
QuaternaryPrimaryCommutator=ToOrder[QuaternaryPrimaryCommutator,20];
DisplayExpression[QuaternaryPrimaryCommutator];

Supercomment@"This concludes our analysis.";

Quit[];
