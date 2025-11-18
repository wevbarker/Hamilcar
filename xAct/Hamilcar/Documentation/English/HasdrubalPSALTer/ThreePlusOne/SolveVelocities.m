(*===================*)
(*  SolveVelocities  *)
(*===================*)

VariablesOfEquation[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=(#/.Equal->List)&;
	Expr//=Flatten;
	Expr//=(Variables/@#)&;
	Expr//=Flatten;
	Expr//=DeleteDuplicates;
Expr];

SolveVelocities[InputExpr_]:=Module[{Expr=InputExpr,
	Constraints,VelocitySolutions,OtherVariables},

	Expr//=Reduce[#,$VelocitiesUp]&;
	Expr//=(#/.Equal->Rule)&;
	Expr//=(#/.And->List)&;

	Constraints=Expr;
	Constraints//=DeleteCases[#,Alternatives@@(Rule[#, _]&/@$VelocitiesUp)]&;
	Constraints//=((First@#-Last@#)&/@#)&;

	OtherVariables=InputExpr;
	OtherVariables//=(VariablesOfEquation/@#)&;
	OtherVariables//=Flatten;
	OtherVariables//=DeleteDuplicates;
	OtherVariables//=Complement[#,$VelocitiesUp]&;

	VelocitySolutions=Expr;
	VelocitySolutions//=DeleteCases[#,Alternatives@@(Rule[#, _]&/@OtherVariables)]&;
	VelocitySolutions//=(MakeRule[Evaluate@(List@@#),
		MetricOn->All,ContractMetrics->True]&/@#)&;
	VelocitySolutions//=Flatten;
{VelocitySolutions,Constraints}];
