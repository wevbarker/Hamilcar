(*==============================*)
(*  MakeDerivativeCombinations  *)
(*==============================*)

MakeDerivativeCombinations[InputExpr_]:=Module[{
	Expr=InputExpr,
	ReciprocalValue,
	ReciprocalRule,
	$TermIsQuotient=False,
	ThirdDTerms,
	SecondDTerms,
	FirstDTerms,
	UndifferentiatedTerms,
	FirstDSurfaceTerms,
	SecondDSurfaceTerms,
	ThirdDSurfaceTerms},

	Expr//=Together;
	ReciprocalValue=Expr;
	ReciprocalValue//=Denominator;
	Expr//=Numerator;
	If[!((CD[-a]@ReciprocalValue)===0),$TermIsQuotient=True];
	If[$TermIsQuotient,
		ReciprocalRule=MakeRule[{GeneralReciprocal[],Evaluate[1/ReciprocalValue]},
			MetricOn->All,ContractMetrics->True];
		Expr*=GeneralReciprocal[];
	];
	Expr//=Variables;
	Expr//=DeleteCases[#,_?ConstantSymbolQ]&;

	ThirdDTerms=Cases[Expr,
		CD[FirstDIndex_]@CD[SecondDIndex_]@CD[ThirdDIndex_]@AnyTensor_,
		Infinity];
	Expr//=Complement[#,ThirdDTerms]&;

	SecondDTerms=Cases[Expr,
		CD[FirstDIndex_]@CD[SecondDIndex_]@AnyTensor_,
		Infinity];
	Expr//=Complement[#,SecondDTerms]&;

	FirstDTerms=Cases[Expr,
		CD[FirstDIndex_]@AnyTensor_,
		Infinity];
	Expr//=Complement[#,FirstDTerms]&;
	UndifferentiatedTerms=Expr;

	FirstDSurfaceTerms=Module[{
		TargetTerm,
		RemainingFirstDTerms,
		DIndex,
		UndifferentiatedTerm},

		RemainingFirstDTerms=FirstDTerms~Complement~{FirstDTerm};
		DIndex=FirstDTerm/.{CD[AnyInd_]@AnyTensor_->AnyInd};
		UndifferentiatedTerm=FirstDTerm/.{CD[FirstDIndex_]@AnyTensor_->AnyTensor};
		RemainingFirstDTerms~AppendTo~UndifferentiatedTerm;
		TargetTerm=Join[UndifferentiatedTerms,RemainingFirstDTerms,SecondDTerms,ThirdDTerms];
		TargetTerm//=Flatten;
		TargetTerm//=(Times@@#)&;
		TargetTerm//=CD@DIndex;
	TargetTerm]~Table~{FirstDTerm,FirstDTerms};

	SecondDSurfaceTerms=Module[{
		TargetTerm,
		RemainingSecondDTerms,
		DIndex,
		UndifferentiatedTerm},

		RemainingSecondDTerms=SecondDTerms~Complement~{SecondDTerm};
		DIndex=SecondDTerm/.{CD[AnyInd_]@CD[AnyOtherInd_]@AnyTensor_->AnyInd};
		UndifferentiatedTerm=SecondDTerm/.{CD[SecondDIndex_]@CD[AnyOtherInd_]@AnyTensor_->CD[AnyOtherInd]@AnyTensor};
		RemainingSecondDTerms~AppendTo~UndifferentiatedTerm;
		TargetTerm=Join[UndifferentiatedTerms,RemainingSecondDTerms,FirstDTerms,ThirdDTerms];
		TargetTerm//=Flatten;
		TargetTerm//=(Times@@#)&;
		TargetTerm//=CD@DIndex;
	TargetTerm]~Table~{SecondDTerm,SecondDTerms};

	ThirdDSurfaceTerms=Module[{
		TargetTerm,
		RemainingThirdDTerms,
		DIndex,
		UndifferentiatedTerm},

		RemainingThirdDTerms=ThirdDTerms~Complement~{ThirdDTerm};
		DIndex=ThirdDTerm/.{CD[AnyInd_]@CD[AnyOtherInd_]@CD[AnyOtherOtherInd_]@AnyTensor_->AnyInd};
		UndifferentiatedTerm=ThirdDTerm/.{CD[ThirdDIndex_]@CD[AnyOtherInd_]@CD[AnyOtherOtherInd_]@AnyTensor_->CD[AnyOtherInd]@CD[AnyOtherOtherInd]@AnyTensor};
		RemainingThirdDTerms~AppendTo~UndifferentiatedTerm;
		TargetTerm=Join[UndifferentiatedTerms,RemainingThirdDTerms,FirstDTerms,SecondDTerms];
		TargetTerm//=Flatten;
		TargetTerm//=(Times@@#)&;
		TargetTerm//=CD@DIndex;
	TargetTerm]~Table~{ThirdDTerm,ThirdDTerms};

	If[$TermIsQuotient,
		FirstDSurfaceTerms//=(#/.ReciprocalRule)&;
		SecondDSurfaceTerms//=(#/.ReciprocalRule)&;
		ThirdDSurfaceTerms//=(#/.ReciprocalRule)&;
	];

{FirstDSurfaceTerms,SecondDSurfaceTerms,ThirdDSurfaceTerms}];
