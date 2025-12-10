(*==================*)
(*  PoissonBracket  *)
(*==================*)

IncludeHeader@"DefSmearingTensor";
IncludeHeader@"CacheContexts";
IncludeHeader@"MonomialPoissonBracket";
IncludeHeader@"../ReloadPackage/MonitorParallel";

Options@PoissonBracket={Parallel->True};

PoissonBracket[InputOperatorOne_,InputOperatorTwo_,OptionsPattern[]]~Y~Module[{
	Expr,
	SmearingTwo,
	SmearingOne,
	OperatorOne=InputOperatorOne,
	OperatorTwo=InputOperatorTwo,
	CallStack,
	ParallelValue=OptionValue@Parallel},
	
	If[!xAct`Hamilcar`Private`$CLI,
		CallStack=PrintTemporary@Dynamic@Refresh[
			GUICallStack@$CallStack,
			TrackedSymbols->{$CallStack}];
	];
	
	If[!$ManualSmearing,
		SmearingOne="SmearingOne"<>(ResourceFunction@"RandomString")@5;
		SmearingOne//=(#~DefSmearingOneTensor~OperatorOne)&;
		OperatorOne*=SmearingOne;
	];
	OperatorOne//=ReplaceDummies;
	OperatorOne//=TotalFrom;

	If[!$ManualSmearing,
		SmearingTwo="SmearingTwo"<>(ResourceFunction@"RandomString")@5;
		SmearingTwo//=(#~DefSmearingTwoTensor~OperatorTwo)&;
		OperatorTwo*=SmearingTwo;
	];
	OperatorTwo//=ReplaceDummies;	
	OperatorTwo//=TotalFrom;
	
	If[ParallelValue,
		CacheContexts[];
	];
	(*If[ParallelValue && !ContextsCachedQ[],
		CacheContexts[];
	];*)

	Module[{LeibnizArray,ExpandedOperatorOne,ExpandedOperatorTwo},
		ExpandedOperatorOne=Expand[OperatorOne];
		ExpandedOperatorOne=(If[Head@#===Plus,List@@#,List@#])&@ExpandedOperatorOne;
		
		ExpandedOperatorTwo=Expand[OperatorTwo];
		ExpandedOperatorTwo=(If[Head@#===Plus,List@@#,List@#])&@ExpandedOperatorTwo;
	
		If[ParallelValue,
			LeibnizArray=Outer[
				(xAct`Hamilcar`Private`NewParallelSubmit@(xAct`Hamilcar`Private`MonomialPoissonBracket[#1,#2]))&,
				ExpandedOperatorOne,ExpandedOperatorTwo,1
			];
			LeibnizArray//=MonitorParallel;
		,
			LeibnizArray=Outer[
				MonomialPoissonBracket[#1,#2]&,
				ExpandedOperatorOne,ExpandedOperatorTwo,1
			];
		];
		
		If[LeibnizArray==={{0}},
			Expr=0,
			Expr=Total[LeibnizArray~Flatten~1];
		];
	];
	Expr//=Recanonicalize;
	If[!xAct`Hamilcar`Private`$CLI,
		FinishDynamic[];
		NotebookDelete@CallStack;
	];
Expr];
