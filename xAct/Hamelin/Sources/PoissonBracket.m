(*==================*)
(*  PoissonBracket  *)
(*==================*)

IncludeHeader@"DefSmearingTensor";
IncludeHeader@"Recanonicalise";
IncludeHeader@"SemiD";
IncludeHeader@"MultiCD";

PoissonBracket[InputOperatorOne_,InputOperatorTwo_]:=Module[{
	ProgressMatrix,
	ProgressOngoing,
	SubExpr,
	Expr=0,
	DerInd,
	SmearingTwo,
	SmearingOne,
	OperatorOne=InputOperatorOne/.ToInertRules,
	OperatorTwo=InputOperatorTwo/.ToInertRules},
	
	SmearingOne="SmearingOne"<>(CreateFile[]~StringTake~(-12));
	(*SmearingOne="SmearingOne"<>(ResourceFunction@"RandomString")@5;*)
	SmearingOne//=(#~DefSmearingOneTensor~OperatorOne)&;
	OperatorOne*=SmearingOne;
	OperatorOne//=ReplaceDummies;

	SmearingTwo="SmearingTwo"<>(CreateFile[]~StringTake~(-12));
	(*SmearingTwo="SmearingTwo"<>(ResourceFunction@"RandomString")@5;*)
	SmearingTwo//=(#~DefSmearingTwoTensor~OperatorTwo)&;
	OperatorTwo*=SmearingTwo;
	OperatorTwo//=ReplaceDummies;	

	(*OperatorOne*=Sqrt[DetG[]];
	OperatorTwo*=Sqrt[DetG[]];*)
	ProgressMatrix=0.01~ConstantArray~{$MaxDerOrd+1,$MaxDerOrd+1};
	ProgressOngoing=PrintTemporary@Dynamic@Refresh[Image[ProgressMatrix/Max@ProgressMatrix],
							TrackedSymbols->{ProgressMatrix}];
	Table[
		Table[
			DerInd=(ToExpression/@Alphabet[])~Take~(-IndM);
			SubExpr=(-1)^IndM*Binomial[IndN,IndM]*(MultiCD@@DerInd)@((SemiD@@(Minus/@DerInd))[OperatorOne,IndN,#1]*SemiD[][OperatorTwo,IndR,#2]-(SemiD@@(Minus/@DerInd))[OperatorOne,IndN,#2]*SemiD[][OperatorTwo,IndR,#1]);
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

	Expr=Expr/.FromInertRules;
	Expr//=Recanonicalise;
	Off[VarD::nouse];
	If[$Strip,
		Expr//=SmearingTwo~VarD~CD;
		Expr//=SmearingOne~VarD~CD;
	];
	On[VarD::nouse];
	(*Expr/=DetG[];*)
	Expr//=Recanonicalise;
Expr];
