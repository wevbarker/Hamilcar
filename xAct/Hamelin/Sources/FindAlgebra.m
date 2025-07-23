(*===============*)
(*  FindAlgebra  *)
(*===============*)

IncludeHeader@"ToHigherDerivativeCanonical";
IncludeHeader@"CollectConstraints";
IncludeHeader@"AugmentWithBoundary";

FindAlgebra[InputBracket_,InputBracketAnsatz_,ConstraintsList_]:=Module[{
	BracketAnsatz=InputBracketAnsatz,	
	BracketAnsatzParameters,
	ParameterSolution=0},

	BracketAnsatz//=(IndexFree/@#)&;
	BracketAnsatz//=(MakeContractionAnsatz[#1,
		ConstantPrefix->#2]&~MapThread~{#,
		(ToString/@Alphabet[])~Take~(Length@#)})&;
	BracketAnsatz//=(ToHigherDerivativeCanonical/@#)&;
	BracketAnsatz//=Total;
	BracketAnsatz//=ToHigherDerivativeCanonical;

	BracketAnsatzParameters=BracketAnsatz;
	BracketAnsatzParameters//=Variables;
	BracketAnsatzParameters//=Cases[#,_?ConstantSymbolQ]&;
	BracketAnsatzParameters//=DeleteDuplicates;
	BracketAnsatzParameters//=Sort;

	ParameterSolution+=BracketAnsatz;
	ParameterSolution-=InputBracket;
	ParameterSolution//=TotalFrom;
	ParameterSolution//=AugmentWithBoundary;
	ParameterSolution//=ToHigherDerivativeCanonical;
	(*ParameterSolution//=(#/.RiemannCD->Zero)&;
	ParameterSolution//=(#/.RicciCD->Zero)&;
	ParameterSolution//=(#/.RicciScalarCD->Zero)&;*)
	ParameterSolution//CollectTensors//Print;

	ParameterSolution//=ToConstantSymbolEquations[#==0]&;
	ParameterSolution//Print;
	ParameterSolution//=Solve;
	ParameterSolution//=First;

	BracketAnsatz//=(#/.ParameterSolution)&;
	BracketAnsatz//=(#/.((#->0)&/@BracketAnsatzParameters))&;
	BracketAnsatz//=ToHigherDerivativeCanonical;
	BracketAnsatz//=(#~CollectConstraints~ConstraintsList)&;
{BracketAnsatz,ParameterSolution}];
