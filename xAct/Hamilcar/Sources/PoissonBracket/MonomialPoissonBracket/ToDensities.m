(*===============*)
(*  ToDensities  *)
(*===============*)

DensitiesToTensors[InputMyExpr_]~Y~Module[{
	MyExpr=InputMyExpr,
	DensitiesToTensorsRules},

	DensitiesToTensorsRules=Module[
		{ConjugateMomentum=#1,
		ConjugateTensorMomentum=#2},

		ConjugateMomentum//=ToIndexFree;
		ConjugateMomentum//=FromIndexFree;
		ConjugateTensorMomentum//=ToIndexFree;
		ConjugateTensorMomentum//=FromIndexFree;
		MakeRule[{Evaluate@ConjugateMomentum,
			Evaluate@(Sqrt[DetG[]]*ConjugateTensorMomentum)},
			MetricOn->All,
			ContractMetrics->True
		]
	]&~MapThread~{$RegisteredMomenta~Append~ConjugateMomentumG,
		$RegisteredTensorMomenta~Append~TensorConjugateMomentumG};
	DensitiesToTensorsRules//=Flatten;
	MyExpr//=(#/.DensitiesToTensorsRules)&;
	MyExpr//=ToCanonical;
	MyExpr//=ContractMetric;
	MyExpr//=ScreenDollarIndices;
MyExpr];

TensorsToDensities[InputMyExpr_]~Y~Module[{
	MyExpr=InputMyExpr,
	TensorsToDensitiesRules},

	TensorsToDensitiesRules=Module[
		{ConjugateMomentum=#1,
		ConjugateTensorMomentum=#2},

		ConjugateMomentum//=ToIndexFree;
		ConjugateMomentum//=FromIndexFree;
		ConjugateTensorMomentum//=ToIndexFree;
		ConjugateTensorMomentum//=FromIndexFree;
		MakeRule[{Evaluate@ConjugateTensorMomentum,
			Evaluate@(ConjugateMomentum/Sqrt[DetG[]])},
			MetricOn->All,
			ContractMetrics->True
		]
	]&~MapThread~{$RegisteredMomenta~Append~ConjugateMomentumG,
		$RegisteredTensorMomenta~Append~TensorConjugateMomentumG};
	TensorsToDensitiesRules//=Flatten;
	MyExpr//=(#/.TensorsToDensitiesRules)&;
	MyExpr//=ToCanonical;
	MyExpr//=ContractMetric;
	MyExpr//=ScreenDollarIndices;
MyExpr];
