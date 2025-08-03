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
	GExpr=0,
	DerInd,
	SmearingTwo,
	SmearingOne,
	OperatorOne=InputOperatorOne,
	OperatorTwo=InputOperatorTwo,
	OperatorOneInert,
	OperatorTwoInert},
	
	SmearingOne="SmearingOne"<>(ResourceFunction@"RandomString")@5;
	SmearingOne//=(#~DefSmearingOneTensor~OperatorOne)&;
	If[!$ManualSmearing,
		OperatorOne*=SmearingOne;
	];
	OperatorOne//=ReplaceDummies;

	SmearingTwo="SmearingTwo"<>(ResourceFunction@"RandomString")@5;
	SmearingTwo//=(#~DefSmearingTwoTensor~OperatorTwo)&;
	If[!$ManualSmearing,
		OperatorTwo*=SmearingTwo;
	];
	OperatorTwo//=ReplaceDummies;	

	Module[{RegisteredMomentum=#1,RegisteredField=#2},
		RegisteredMomentum//=ToIndexFree;
		RegisteredMomentum//=FromIndexFree;
		RegisteredField//=ToIndexFree;
		RegisteredField//=FromIndexFree;

		Expr+=VarD[#1,CD][OperatorOne]*VarD[#2,CD][OperatorTwo];
		Expr-=VarD[#1,CD][OperatorTwo]*VarD[#2,CD][OperatorOne];
	]&~MapThread~{$RegisteredFields,$RegisteredMomenta};

	If[$DynamicalMetric,
		GExpr+=TensorsToDensities@Times[VarD[G[-a,-b],
			CD][OperatorOne//DensitiesToTensors],
			VarD[ConjugateMomentumG[a,b],CD][OperatorTwo]];
		GExpr-=TensorsToDensities@Times[VarD[G[-a,-b],
			CD][OperatorTwo//DensitiesToTensors],
			VarD[ConjugateMomentumG[a,b],CD][OperatorOne]];
		Module[{ConjugateTensorMomentum=RegisteredTensorMomentum},
			ConjugateTensorMomentum//=ToIndexFree;
			ConjugateTensorMomentum//=FromIndexFree;
			GExpr+=TensorsToDensities@Times[ConjugateTensorMomentum,
				-VarD[G[-x,-y],CD][Sqrt[DetG[]]]/Sqrt[DetG[]],
				VarD[ConjugateTensorMomentum,
					CD][OperatorOne//DensitiesToTensors],
				VarD[ConjugateMomentumG[x,y],CD][OperatorTwo]];
			GExpr-=TensorsToDensities@Times[ConjugateTensorMomentum,
				-VarD[G[-x,-y],CD][Sqrt[DetG[]]]/Sqrt[DetG[]],
				VarD[ConjugateTensorMomentum,
					CD][OperatorTwo//DensitiesToTensors],
				VarD[ConjugateMomentumG[x,y],CD][OperatorOne]];
		]~Table~{RegisteredTensorMomentum,
			$RegisteredTensorMomenta~Append~TensorConjugateMomentumG};
	];

	Expr+=GExpr;

	Expr//=Recanonicalise;
Expr];
