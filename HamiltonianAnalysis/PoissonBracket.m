(*==================*)
(*  PoissonBracket  *)
(*==================*)

Get@FileNameJoin@{$ThisDirectory,"HamiltonianAnalysis","PoissonBracket","SmearInput.m"};
Get@FileNameJoin@{$ThisDirectory,"HamiltonianAnalysis","PoissonBracket","SemiD.m"};

PoissonBracket[InputLeftOperand_,InputRightOperand_]:=Module[{
	ProgressMatrix,
	ProgressOngoing,
	SubExpr,
	Expr,
	DerInd,
	LeftOperand=InputLeftOperand/.ToInertRules,
	RightOperand=InputRightOperand/.ToInertRules},

	LeftOperand//=(#~SmearOperand~Left)&;
	RightOperand//=(#~SmearOperand~Right)&;

	ProgressMatrix=0.01~ConstantArray~{$MaxDerOrd+1,$MaxDerOrd+1};

	ProgressOngoing=PrintTemporary@Dynamic@Refresh[Image[ProgressMatrix/Max@ProgressMatrix],
							TrackedSymbols->{ProgressMatrix}];

	Expr=0;

	Table[
		Table[
			DerInd=(ToExpression/@Alphabet[])~Take~(-IndM);
			SubExpr=(-1)^IndM*Binomial[IndN,IndM]*(MultiCD@@DerInd)@((SemiD@@(Minus/@DerInd))[LeftOperand,IndN,#1]*SemiD[][RightOperand,IndR,#2]-(SemiD@@(Minus/@DerInd))[LeftOperand,IndN,#2]*SemiD[][RightOperand,IndR,#1]);
			SubExpr=SubExpr/.FromInertRules;
			SubExpr//=ToCanonical;
			SubExpr//=ContractMetric;
			SubExpr//=ScreenDollarIndices;
			Expr+=SubExpr;
			ProgressMatrix[[IndN+1,IndR+1]]+=1/(IndN+1);
		,
			{IndM,0,IndN}
		];
	,
		{IndN,0,$MaxDerOrd},{IndR,0,$MaxDerOrd}
	]&~MapThread~{RegisteredFields,RegisteredMomenta};

	NotebookDelete@ProgressOngoing;

	Expr=Expr/.FromInertRules;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
Expr];

(*2406.09526*)
(*Wave functional*)
