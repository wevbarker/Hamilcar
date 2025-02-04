(*==================*)
(*  PoissonBracket  *)
(*==================*)

IncludeHeader@"DefSmearingTensor";
IncludeHeader@"SemiD";

PoissonBracket[InputLeftOperand_,InputRightOperand_]:=Module[{
	ProgressMatrix,
	ProgressOngoing,
	SubExpr,
	Expr,
	DerInd,
	SmearingR,
	SmearingL,
	LeftOperand=InputLeftOperand/.ToInertRules,
	RightOperand=InputRightOperand/.ToInertRules},

	SmearingL="SmearingL"<>(ResourceFunction@"RandomString")@5;
	SmearingL//=(#~DefSmearingTensor~LeftOperand)&;
	LeftOperand*=SmearingL;
	LeftOperand//=ReplaceDummies;

	SmearingR="SmearingR"<>(ResourceFunction@"RandomString")@5;
	SmearingR//=(#~DefSmearingTensor~RightOperand)&;
	RightOperand*=SmearingR;
	RightOperand//=ReplaceDummies;
	
(*
	LeftOperand*=Sqrt[DetG[]];
	RightOperand*=Sqrt[DetG[]];
*)
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

(*
	LeftFactor=InputLeftOperand/.ToInertRules;
	RightFactor=InputRightOperand/.ToInertRules;
	LeftFactor//=(#~SmearFactor~Left)&;
	RightFactor//=(#~SmearFactor~Right)&;
*)

	Off[VarD::nouse];
	Expr//=VarD[SmearingL,CD];	
	Expr//=VarD[SmearingR,CD];	
	On[VarD::nouse];
	
	(*Expr/=DetG[];*)
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;

Expr];
