(*===============*)
(*  FindAlgebra  *)
(*===============*)

IncludeHeader@"CollectConstraints";
IncludeHeader@"NewUtils";
(*IncludeHeader@"ToHigherToSymmetrizedCanonical";*)

Options@FindAlgebra={Method->Solve,Constraints->{},Verify->False};
FindAlgebra[InputBulkBracket_,InputSchematicAnsatz_,OptionsPattern[]]~Y~Module[{
	CallStack,
	BulkBracket=InputBulkBracket,
	SchematicAnsatz=InputSchematicAnsatz,	
	BulkAnsatz,
	OutputBulkBracket,
	BoundaryAnsatz,
	DDIAnsatz,
	BasicDDIAnsatz,
	AdvancedDDIAnsatz,
	DDIAnsatzParameters,
	MultiTensorRules,
	BulkAnsatzParameters,
	BoundaryAnsatzParameters,
	ParameterSolution=0},

	If[!xAct`Hamilcar`Private`$CLI,
		CallStack=PrintTemporary@Dynamic@Refresh[
			GUICallStack@$CallStack,
			TrackedSymbols->{$CallStack}];
	];

	Block[{DetG},
		DetG[]:=1;
		BulkAnsatz=SchematicAnsatz;
		BulkAnsatz//=MakePermutedBulk;
		BulkAnsatz//=MakeSchematicBulk;
		BulkAnsatz//=MakeBulkAnsatz;
		OutputBulkBracket=BulkAnsatz;
		BulkAnsatzParameters=BulkAnsatz;
		BulkAnsatzParameters//=ExtractParameters;
		BulkAnsatz//=TotalFrom;

		DDIAnsatz=BulkAnsatz;
		DDIAnsatz//=(#/.{RicciScalarCD->Zero})&;
		DDIAnsatz//=RecoverBasicSchematicAnsatz;

		BasicDDIAnsatz=DDIAnsatz;
		BasicDDIAnsatz//=MakeBasicDDIs;

		AdvancedDDIAnsatz=DDIAnsatz;
		AdvancedDDIAnsatz//=ExtractPowerGradients;
		AdvancedDDIAnsatz//=DevelopAllScalars;
		MultiTensorRules=$RequiredMultiTensors;
		MultiTensorRules//=DevelopAllDDIs;
		MultiTensorRules//=AllDDIsToMultiTensorRules;
		AdvancedDDIAnsatz//=(#~OuterRules~MultiTensorRules)&;

		DDIAnsatz=BasicDDIAnsatz+AdvancedDDIAnsatz;
		DDIAnsatz//=CollectTensors[#,CollectMethod->ToExpandedCanonical]&;
		DDIAnsatzParameters=DDIAnsatz;
		DDIAnsatzParameters//=ExtractParameters;

		BoundaryAnsatz=BulkAnsatz;
		BoundaryAnsatz//=(#/.{RicciScalarCD->Zero})&;
		BoundaryAnsatz//=RecoverSchematicAnsatz;
		BoundaryAnsatz//=CurvatureReduction;
		BoundaryAnsatz//=MakeSchematicBoundaryCurrent;
		BoundaryAnsatz//=BoundaryCurrentToBoundary;
		BoundaryAnsatzParameters=BoundaryAnsatz;
		BoundaryAnsatzParameters//=ExtractParameters;
		BoundaryAnsatzParameters//=(#~Join~DDIAnsatzParameters)&;
		BulkBracket//=TotalFrom;
		BulkBracket//=CleanInputBracket;
		ParameterSolution+=BulkBracket;
		ParameterSolution-=BulkAnsatz;
		ParameterSolution-=BoundaryAnsatz;
		ParameterSolution-=DDIAnsatz;
		ParameterSolution//=CollectTensors[#,CollectMethod->ToExpandedCanonical]&;
		ParameterSolution//=ObtainSolution[#,
			BulkAnsatzParameters,BoundaryAnsatzParameters,
			Method->OptionValue@Method]&;

		BulkBracket=InputBulkBracket;
		BulkBracket//=TotalFrom;
	];
	OutputBulkBracket//=(#/.ParameterSolution)&;
	OutputBulkBracket//=CollectTensors[#,CollectMethod->ToExpandedCanonical]&;
	BulkAnsatz//=(#/.ParameterSolution)&;
	BulkAnsatz//=CollectTensors[#,CollectMethod->ToExpandedCanonical]&;
	If[OptionValue@Constraints=!={},
		OutputBulkBracket//=(#~CollectConstraints~(OptionValue@Constraints))&;
	];
	If[OptionValue@Verify,
		BulkBracket~VerifyResult~BulkAnsatz;
	];

	If[!xAct`Hamilcar`Private`$CLI,
		FinishDynamic[];
		NotebookDelete@CallStack;
	];
OutputBulkBracket];
