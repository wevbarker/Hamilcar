(*==================*)
(*  PoissonBracket  *)
(*==================*)

IncludeHeader@"DefSmearingTensor";
IncludeHeader@"Recanonicalise";
IncludeHeader@"SemiD";
IncludeHeader@"MultiCD";
IncludeHeader@"ToDensities";

PoissonBracket[InputOperatorOne_,InputOperatorTwo_]:=Module[{
	ProgressMatrix,
	ProgressOngoing,
	SubExpr,
	Expr=0,
	DerInd,
	SmearingTwo,
	SmearingOne,
	OperatorOne=InputOperatorOne,
	OperatorTwo=InputOperatorTwo,
	OperatorOneInert,
	OperatorTwoInert},
	
	SmearingOne="SmearingOne"<>(CreateFile[]~StringTake~(-12));
	(*SmearingOne="SmearingOne"<>(ResourceFunction@"RandomString")@5;*)
	SmearingOne//=(#~DefSmearingOneTensor~OperatorOne)&;
	If[!$ManualSmearing,
		OperatorOne*=SmearingOne;
	];
	OperatorOne//=ReplaceDummies;

	SmearingTwo="SmearingTwo"<>(CreateFile[]~StringTake~(-12));
	(*SmearingTwo="SmearingTwo"<>(ResourceFunction@"RandomString")@5;*)
	SmearingTwo//=(#~DefSmearingTwoTensor~OperatorTwo)&;
	If[!$ManualSmearing,
		OperatorTwo*=SmearingTwo;
	];
	OperatorTwo//=ReplaceDummies;	

	OperatorOneInert=OperatorOne/.ToInertRules;
	OperatorTwoInert=OperatorTwo/.ToInertRules;

	(*OperatorOne*=Sqrt[DetG[]];
	OperatorTwo*=Sqrt[DetG[]];*)
(*ProgressMatrix=0.01~ConstantArray~{$MaxDerOrd+1,$MaxDerOrd+1};
	ProgressOngoing=PrintTemporary@Dynamic@Refresh[Image[ProgressMatrix/Max@ProgressMatrix],
							TrackedSymbols->{ProgressMatrix}];

	Table[
		Table[
			DerInd=(ToExpression/@Alphabet[])~Take~(-IndM);
			SubExpr=(-1)^IndM*Binomial[IndN,IndM]*(MultiCD@@DerInd)@((SemiD@@(Minus/@DerInd))[OperatorOneInert,IndN,#1]*SemiD[][OperatorTwoInert,IndR,#2]-(SemiD@@(Minus/@DerInd))[OperatorOneInert,IndN,#2]*SemiD[][OperatorTwoInert,IndR,#1]);
			SubExpr=SubExpr/.FromInertRules;
			SubExpr//=Recanonicalise;
			Expr+=SubExpr;
			ProgressMatrix[[IndN+1,IndR+1]]+=1/(IndN+1);
		,
			{IndM,0,IndN}
		];
	,
		{IndN,0,$MaxDerOrd},{IndR,0,$MaxDerOrd}
	]&~MapThread~{$RegisteredFields,$RegisteredMomenta};
	NotebookDelete@ProgressOngoing;
	*)

	(*OperatorOne*=PseudoDeltaOne[];
	OperatorTwo*=PseudoDeltaTwo[];*)

	(*OperatorOne/=Sqrt[DetG[]];
	OperatorTwo/=Sqrt[DetG[]];*)
	Expr=0;
	Expr+=Module[{Expr,DensityOperatorOne=OperatorOne,DensityOperatorTwo=OperatorTwo},
		If[True,
			DensityOperatorOne//=ToDensities;
			DensityOperatorTwo//=ToDensities;
		];
		Expr=VarD[G[-a,-b],CD][DensityOperatorOne]*VarD[ConjugateMomentumG[a,b],CD][DensityOperatorTwo]-VarD[G[-a,-b],CD][DensityOperatorTwo]*VarD[ConjugateMomentumG[a,b],CD][DensityOperatorOne];
		If[$NewDensities,
			Expr//=FromDensities;
		];
		(*Expr//=PseudoDeltaOne[]~VarD~CD;
		Expr//=PseudoDeltaTwo[]~VarD~CD;*)
	Expr];

	Expr=Expr/.FromInertRules;
	Expr//=Recanonicalise;
	Off[VarD::nouse];
	If[$Strip,
		If[!$ManualSmearing,
			Expr//=SmearingTwo~VarD~CD;
			Expr//=SmearingOne~VarD~CD;
		];
	];
	On[VarD::nouse];
	(*Expr/=DetG[];*)
	Expr//=Recanonicalise;
Expr];
