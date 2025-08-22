(*======================*)
(*  CurvatureExtension  *)
(*======================*)

PermuteAnsatz[InputExpr_]~Y~Module[{
	Expr=InputExpr,
	CDNumber=InputExpr,
	CDPositions},

	CDNumber//=(#/.{CD->1})&;
	CDNumber//=(#~Cases~(_?NumberQ))&;
	CDNumber//=Total;
	CDPositions=(Range@(Length@Expr-CDNumber))~Tuples~CDNumber;
	CDPositions//=(Sort/@#)&;
	CDPositions//=DeleteDuplicates;
	CDPositions//=Sort;
	Expr//=(#~DeleteCases~CD)&;
	Expr//=(#~ConstantArray~(Length@CDPositions))&;
	Expr//=MapThread[
		Module[{SubExpr=#1,CDPositionsActual=#2},
			(SubExpr[[#]]//=CD)&/@CDPositionsActual;
			SubExpr//=(Times@@#)&;
			SubExpr]&,
		{#,CDPositions}]&;
	Expr//=DeleteDuplicates;
	Expr//=Sort;
Combinations@@Expr];

PermuteAnsatzIfVarList[InputExpr_]~Y~If[(Depth@InputExpr)===2,
	InputExpr//PermuteAnsatz,
	InputExpr];

MakePermutedBulk[InputExpr_]~Y~(PermuteAnsatzIfVarList//@InputExpr);

ExpandAnsatz[InputExpr_]~Y~Module[{Expr=InputExpr},
	If[
		!(Head@Expr===Combinations)
	,
		Expr//=(#/.{Combinations->List})&;
		Expr~PrependTo~Times;
		Expr//=(Outer@@#)&;
		Expr//=Flatten;
	,
		Expr//=(#/.{Combinations->List})&;
	];
Expr];

MakeSchematicBulk[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=(ExpandAnsatz/@#)&;
	Expr//=Flatten;
	Expr//=DeleteDuplicates;
Expr];

MakeBulkAnsatz[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=(IndexFree/@#)&;
	Expr//=(MakeContractionAnsatz[#1,
		ConstantPrefix->#2]&~MapThread~{#,
		(DeleteDuplicates@Flatten@Outer[(ToString@#1<>ToString@#2)&,
			Alphabet[],Alphabet[]])~Take~(Length@#)})&;
	Expr//=Total;
	Expr//=CollectTensors[#,CollectMethod->ToSymmetrizedCanonical]&;
Expr];

MakeBoundaryCurrentAnsatz[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=(IndexFree/@#)&;
	Expr//=(MakeContractionAnsatz[#1,IndexList@a,
		ConstantPrefix->#2]&~MapThread~{#,
		("S"<>ToString@#)&/@(Range@Length@#)})&;
	Expr//=Total;
	Expr//=CollectTensors;
Expr];

MakeSchematicBoundaryCurrent[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=(Flatten/@#)&;
	Expr//=(Sort/@#)&;
	Expr//=(#~Cases~(_?((#~MemberQ~CD)&)))&;
	Expr//=((#~Delete~(First@Flatten@(#~Position~CD)))&/@#)&;
	Expr//=(PermuteAnsatz/@#)&;
	Expr//=((List@@#)&/@#)&;
	Expr//=Flatten;
	Expr//=DeleteDuplicates;
	Expr//=Sort;
	Expr//=MakeBoundaryCurrentAnsatz;
Expr];

Options@Repartition={ExpandAll->True};
Repartition[InputExpr_List,PartitionLength_Integer,OptionsPattern[]]~Y~Module[{
	Expr=InputExpr},
	Expr//=Flatten;
	Expr//=Total;
	If[OptionValue@ExpandAll,Expr//=Expand];
	Expr=(If[Head@#===Plus,List@@#,List@#])&@(Expr);
	Expr//=Flatten;
	Expr//=RandomSample;
	Expr//=Partition[#,UpTo@PartitionLength]&;
	Expr//=(Total/@#)&;	
Expr];

ToSymmetrizedCanonical[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=ContractMetric;
	Expr//=ToCanonical;
	Expr//=SymmetrizeCovDs;
	Expr//=(#/.CurvatureRelationsBianchi[CD,Ricci])&;
	Expr//=ContractMetric;
	Expr//=ToCanonical;
Expr];

ToExpandedCanonical[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=ContractMetric;
	Expr//=ToCanonical;
	Expr//=ExpandSymCovDs;
	Expr//=(#/.CurvatureRelationsBianchi[CD,Ricci])&;
	Expr//=ContractMetric;
	Expr//=ToCanonical;
Expr];

ComputeDivergence[InputExpr_]:=Module[{Expr=InputExpr},
	Expr//=CD[-a];
	Expr//=CollectTensors[#,CollectMethod->ToSymmetrizedCanonical]&;
Expr];

BoundaryCurrentToBoundary[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=(If[Head@#===Plus,List@@#,List@#])&;
	Expr//=(#~Repartition~10)&;
	CacheContexts[];
	Expr//=Map[(xAct`Hamilcar`Private`NewParallelSubmit@(xAct`Hamilcar`Private`ComputeDivergence[#]))&,#]&;
	Expr//=MonitorParallel;
	Expr//=Total;
	Expr//=CollectTensors[#,CollectMethod->ToSymmetrizedCanonical]&;
Expr];

MakeCurvatureReduction[InputExpr_]~Y~Module[{Expr=InputExpr,ReturnExpr={}},
	While[
		ReducibleQ@Expr
	,
		Expr//=(#~Delete~(First@Flatten@(#~Position~CD)))&;
		Expr//=(#~Delete~(First@Flatten@(#~Position~CD)))&;
		Expr~AppendTo~RicciCD;
		Expr//=Sort;
		ReturnExpr~AppendTo~Expr;
	];
ReturnExpr];

ReducibleQ[InputExpr_]~Y~((InputExpr~Count~CD)>1);

CurvatureReduction[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=(#/.{RicciCD->{CD,CD}})&;
	Expr//=(Flatten/@#)&;
	Expr//=(#~Cases~(_?ReducibleQ))&;
	Expr//=(MakeCurvatureReduction/@#)&;
	Expr//=(#~Flatten~1)&;
	Expr//=DeleteDuplicates;
	Expr//=Sort;
	Expr//=(#~Join~InputExpr)&;
Expr];

CleanInputBracket[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=Expand;
	Expr//=SymmetrizeCovDs;
	Expr//=CollectTensors[#,CollectMethod->ToSymmetrizedCanonical]&;
Expr];

ExtractParameters[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=Variables;
	Expr//=Cases[#,_?ConstantSymbolQ]&;
	Expr//=DeleteDuplicates;
	Expr//=Sort;
Expr];

MinimiseExpr[InputExpr_,InputBulkAnsatzParameters_]~Y~Module[{Expr=InputExpr},
	Expr//=(InputBulkAnsatzParameters/.#)&;
	Expr//=Variables;
	Expr//=(InputBulkAnsatzParameters~Intersection~#)&;
	Expr//=((#->0)&/@#)&;
	Expr//=(#~Join~(InputExpr/.#))&;
Expr];

FindAlgebra::NoSolution="No solution could be found. Try a different schematic ansatz or a different \"Method\".";
SolveWithSolve[InputExpr_,InputAnsatzParameters_]~Y~Module[{Expr=InputExpr},
	Expr//=(#~Reduce~InputAnsatzParameters)&;
	Expr//=(#~Solve~InputAnsatzParameters)&;
	(Expr//=First)~Check~(Throw@Message@FindAlgebra::NoSolution);
Expr];

ListRescaledVariables[InputExpr_,
		InputRescalingRules_,
		InputBulkAnsatzParameters_,
		InputBoundaryAnsatzParameters_]~Y~Module[{Expr=InputRescalingRules,
	RescaledVariables,
	PristineVariables},
	RescaledVariables=Sort@DeleteDuplicates@(First/@InputRescalingRules);
	PristineVariables=(InputBulkAnsatzParameters~Join~InputBoundaryAnsatzParameters)~Complement~RescaledVariables;
	RescaledVariables//=(#~Intersection~(Variables@InputExpr))&;
	PristineVariables//=(#~Intersection~(Variables@InputExpr))&;
{RescaledVariables,PristineVariables}];

LeverageDimensionality[InputExpr_,
	InputRescalingRules_,
	InputBulkAnsatzParameters_,
	InputBoundaryAnsatzParameters_]~Y~Module[{Expr=InputExpr,
		ReducedEquation=InputExpr,
		RescaledVariables,
		PristineVariables,
		RescalingRules=InputRescalingRules},
	Expr//=(#/.InputRescalingRules)&;
	Expr//=(#/.{(LHS_==RHS_)->LHS-RHS})&;
	{RescaledVariables,PristineVariables}=ListRescaledVariables[
		Expr,
		InputRescalingRules,
		InputBulkAnsatzParameters,
		InputBoundaryAnsatzParameters];
	If[!(Length@RescaledVariables===0),
		Expr//=Module[{Expr=#},(Expr~Coefficient~#)&/@RescaledVariables]&;
		Expr//=PolynomialGCD@@#&;
		Expr//=FactorList;
		Expr//=(Power@@#&/@#)&;
		Expr//=DeleteCases[#,_?NumericQ]&;
		Expr//=Times@@#&;
		RescalingRules~AppendTo~Map[(#->Expr*#)&,PristineVariables];
		RescalingRules//=Flatten;
		RescalingRules//=DeleteDuplicates;
		RescalingRules//=Sort;	
	];
RescalingRules];

ImposeRescaling[InputExpr_,
		InputRescalingRules_,
		InputBulkAnsatzParameters_,
		InputBoundaryAnsatzParameters_]~Y~Module[{Expr=InputExpr,TotalFactor},
	Expr//=(#/.InputRescalingRules)&;
	Expr//=(#/.{(LHS_==RHS_)->LHS-RHS})&;
	TotalFactor=Expr;
	TotalFactor//=Module[{Expr=#},
		(Expr~Coefficient~#)&/@(InputBulkAnsatzParameters~Join~InputBoundaryAnsatzParameters)]&;
	TotalFactor//=PolynomialGCD@@#&;
	TotalFactor//=FactorList;
	TotalFactor//=(Power@@#&/@#)&;
	TotalFactor//=DeleteCases[#,_?NumericQ]&;
	TotalFactor//=Times@@#&;
	Expr/=TotalFactor;
	Expr//=(#==0)&;
	Expr//=Simplify;
	(*Expr//Print;*)
Expr];

SolveWithLinearSolve[InputExpr_,
	InputBulkAnsatzParameters_,
	InputBoundaryAnsatzParameters_]~Y~Module[{Expr=InputExpr,
		RescalingRules,OldRescalingRules,$KeepRescaling},
	Expr//=(#/.{And->List})&;
	Expr//=Sort;
	RescalingRules=MapThread[(#1->#2)&,
		{InputBulkAnsatzParameters,
		InputBulkAnsatzParameters}];
	$KeepRescaling=True;
	While[$KeepRescaling,
		OldRescalingRules=RescalingRules;
		(RescalingRules=LeverageDimensionality[#,
			RescalingRules,
			InputBulkAnsatzParameters,
			InputBoundaryAnsatzParameters])&/@Expr;
		If[(Length@RescalingRules)===(Length@OldRescalingRules),
			$KeepRescaling=False,
			$KeepRescaling=True];
	];
	(*RescalingRules//Print;*)
	Expr//=(ImposeRescaling[#,
		RescalingRules,
		InputBulkAnsatzParameters,
		InputBoundaryAnsatzParameters]&/@#)&;
	Expr//=(#~CoefficientArrays~(InputBulkAnsatzParameters~Join~InputBoundaryAnsatzParameters))&;
	Expr//=Normal;
	(Expr//=((Last@#)~LinearSolve~(First@#))&)~Check~(Throw@Message@FindAlgebra::NoSolution);
	Expr//=MapThread[(#1->-#2)&,{(InputBulkAnsatzParameters~Join~InputBoundaryAnsatzParameters),#}]&;
Expr];

Options@ObtainSolution={Method->Solve};
ObtainSolution[InputExpr_,
	InputBulkAnsatzParameters_,
	InputBoundaryAnsatzParameters_,
	OptionsPattern[]]~Y~Module[{
	Expr=InputExpr,
	BulkAnsatzParameters=InputBulkAnsatzParameters,
	BoundaryAnsatzParameters=InputBoundaryAnsatzParameters},
	Expr//=ToConstantSymbolEquations[#==0]&;
	Switch[OptionValue@Method,
		Solve,
		Expr//=(#~SolveWithSolve~(BulkAnsatzParameters~Join~BoundaryAnsatzParameters))&,
		LinearSolve,
		Expr//=SolveWithLinearSolve[#,
			BulkAnsatzParameters,
			BoundaryAnsatzParameters]&];
	Expr//=(#~MinimiseExpr~(BulkAnsatzParameters~Join~BoundaryAnsatzParameters))&;
Expr];

ObtainEffectiveSmearingFunctions[InputBulkBracket_]~Y~Module[{Expr=InputBulkBracket,
		AllVariables,
		EffectiveSmearingFunctions},
	Expr//=Expand;
	Expr//=(If[Head@#===Plus,List@@#,List@#])&;
	Expr//=Block[{CD,Expr=#},
		CD[AnyInd___]@AnyVar_:=AnyVar;
		Expr//=Variables;
		Expr//=(#~Complement~Cases[#,_?ConstantSymbolQ])&;
		Expr//=(Head/@#)&;
		Expr//=Sort;
		Expr]&/@#&;
	AllVariables=Expr;
	AllVariables//=Flatten;
	AllVariables//=DeleteDuplicates;
	AllVariables//=Sort;
	EffectiveSmearingFunctions={};
	If[(DeleteDuplicates@(Count[#,SpecVar]&/@Expr)==={1}),EffectiveSmearingFunctions~AppendTo~SpecVar]~Table~{SpecVar,AllVariables};
	EffectiveSmearingFunctions//=(IndexFree/@#)&;
	EffectiveSmearingFunctions//=(FromIndexFree/@#)&;
EffectiveSmearingFunctions];

SmearingVarD[InputExpr_,InputEffectiveSmearingFunction_]~Y~Module[{Expr=InputExpr},
	Expr//=VarD[InputEffectiveSmearingFunction,CD];
	Expr//=CollectTensors[#,CollectMethod->ToSymmetrizedCanonical]&;
	Expr//=ScreenDollarIndices;
Expr];

FindAlgebra::Unverified="Unverified with respect to the effective smearing function `1`.";
VerifyWithRespectToEffectiveSmearingFunction[InputBulkBracket_,
	InputBulkAnsatz_,
	InputEffectiveSmearingFunction_]~Y~Module[{BulkBracket=InputBulkBracket,
		BulkAnsatz=InputBulkAnsatz,TotalDifference},
	BulkBracket//=(#~SmearingVarD~InputEffectiveSmearingFunction)&;
	BulkAnsatz//=(#~SmearingVarD~InputEffectiveSmearingFunction)&;
	TotalDifference=BulkBracket-BulkAnsatz;
	TotalDifference//=CollectTensors[#,CollectMethod->ToSymmetrizedCanonical]&;
	If[TotalDifference===0,
		Print@("** Verified with respect to the effective smearing function "<>ToString@InputEffectiveSmearingFunction<>".");
	,
		(FindAlgebra::Unverified)~Message~(InputEffectiveSmearingFunction);
	];
];

VerifyResult[InputBulkBracket_,
	InputBulkAnsatz_]~Y~Module[{BulkBracket=InputBulkBracket,
		BulkAnsatz=InputBulkAnsatz,
		EffectiveSmearingFunctions=InputBulkBracket},

	EffectiveSmearingFunctions//=ObtainEffectiveSmearingFunctions;
	VerifyWithRespectToEffectiveSmearingFunction[BulkBracket,
		BulkAnsatz,#]&/@EffectiveSmearingFunctions;
];

ConstantCoefficientQ[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=Variables;
	Expr//=(ConstantSymbolQ/@#)&;
	Expr//=(And@@#)&;
Expr];

MakeSchematic[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=FactorList;
	Expr//=(Power@@#&/@#)&;
	Expr//=DeleteCases[#,_?NumericQ]&;
	Expr//=DeleteCases[#,_?ConstantCoefficientQ]&;
	(*May be necessary to stiffen this up for other constant coefficients*)
	Expr//=Times@@#&;
	Expr//=ToIndexFree;
	Expr//=(#/.{IndexFree->Identity})&;
	Expr//=FactorList;
	Expr//=((First@#)~ConstantArray~(Last@#))&/@#&;
	Expr//=DeleteCases[#,{1}]&;
	Expr//=Block[{CD,Expr=#},
		CD[AnyHead_]:={CD,AnyHead};Expr//=Flatten;Expr]&/@#&;
Expr];

RecoverSchematicAnsatz[InputExpr_]~Y~Module[{Expr=InputExpr},
	Expr//=Expand;
	Expr//=(If[Head@#===Plus,List@@#,List@#])&;
	Expr//=(MakeSchematic/@#)&;
	Expr//=DeleteDuplicates;
	Expr//=Sort;
Expr];
