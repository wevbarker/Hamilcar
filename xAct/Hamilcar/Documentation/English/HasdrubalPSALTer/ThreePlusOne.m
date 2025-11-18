(*================*)
(*  ThreePlusOne  *)
(*================*)

Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","ExtractFields.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","PrepareAutomaticRules.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","FieldThreePlusOne.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","ActivateTimeD.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","ProjectMetric.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","ApplyDerivativeRules.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","DefineMomenta.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","SolveVelocities.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne","ConstructCanonicalHamiltonian.m"}];

DefTensor[InverseInducedMetric[a,b],M4,Symmetric[{a,b}],PrintAs->"H"];
GToInverseInducedMetric=MakeRule[{G[a,b],InverseInducedMetric[a,b]+V[a]V[b]},
	MetricOn->All,ContractMetrics->True];
AutomaticRules[V,MakeRule[{InverseInducedMetric[a,b]*V[-b],0},
	MetricOn->All,ContractMetrics->True]];
AutomaticRules[V,MakeRule[{CD[a]@V[b],0},
	MetricOn->All,ContractMetrics->True]];
InverseInducedMetricToGHack=MakeRule[{InverseInducedMetric[a,b],-G[a,b]},
	MetricOn->All,ContractMetrics->True];

ThreePlusOne[InputExpr_]:=Module[{
	FieldNames=InputExpr,
	VelocitiesToMultipliersRules,
	ThreePlusOneLagrangian=InputExpr,
	Expr,
	CanonicalHamiltonian,
	VelocitySolutions,
	Constraints},

	FieldNames//=ExtractFields;

	$DerivativeRules={};
	$CanonicalFields={};
	$ConjugateMomenta={};
	$LagrangeMultipliers={};
	$Velocities={};
	Do[
		PrepareAutomaticRules[FieldName],
		{FieldName,FieldNames}
	];	
	Do[
		ThreePlusOneLagrangian//=FieldThreePlusOne[#,FieldName]&,
		{FieldName,FieldNames}
	];	

	VelocitiesToMultipliersRules=MapThread[MakeRule[
		{Evaluate@#1,Evaluate@#2},
		MetricOn->All,ContractMetrics->True]&,
		{(FromIndexFree@ToIndexFree@#)&/@$Velocities,
		(FromIndexFree@ToIndexFree@#)&/@$LagrangeMultipliers}];
	VelocitiesToMultipliersRules//=Flatten;

	Comment@"The Lagrangian after 3+1 decomposition.";
	ThreePlusOneLagrangian//=ActivateTimeD;
	ThreePlusOneLagrangian//=ProjectMetric;
	ThreePlusOneLagrangian//=ApplyDerivativeRules;
	ThreePlusOneLagrangian//=ApplyDerivativeRules;
	ThreePlusOneLagrangian//=ApplyDerivativeRules;
	ThreePlusOneLagrangian//=(#/.InverseInducedMetricToGHack)&;
	ThreePlusOneLagrangian//=ToCanonical;
	ThreePlusOneLagrangian//=ContractMetric;
	ThreePlusOneLagrangian//=ScreenDollarIndices;
	ThreePlusOneLagrangian//=(#/.{V->Zero})&;
	ThreePlusOneLagrangian//=ToCanonical;
	ThreePlusOneLagrangian//=ContractMetric;
	ThreePlusOneLagrangian//=ScreenDollarIndices;
	ThreePlusOneLagrangian//DisplayExpression;

	Comment@"The total Hamiltonian.";
	$Velocities//=((FromIndexFree@ToIndexFree@#)&/@#)&;
	$VelocitiesUp=$Velocities/.{SomeIndex_?TangentM4`Q->-SomeIndex};
	$ConjugateMomenta//=((FromIndexFree@ToIndexFree@#)&/@#)&;
	Expr=ThreePlusOneLagrangian;
	Expr//=DefineMomenta;
	{VelocitySolutions,Constraints}=Expr//SolveVelocities;
	CanonicalHamiltonian=ThreePlusOneLagrangian;
	CanonicalHamiltonian//=ConstructCanonicalHamiltonian;
	CanonicalHamiltonian//=(#/.VelocitySolutions)&;
	CanonicalHamiltonian//=ToCanonical;
	CanonicalHamiltonian//=ContractMetric;
	CanonicalHamiltonian//=ScreenDollarIndices;
	CanonicalHamiltonian//=(#/.VelocitiesToMultipliersRules)&;
	CanonicalHamiltonian//DisplayExpression;
Expr];
