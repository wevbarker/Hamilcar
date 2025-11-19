(*============*)
(*  DefPower  *)
(*============*)

Options@DefPower={QuantitySymbol->"\[CapitalOmega]"};
DefPower[InputTensorHead_,OptionsPattern[]]:=Module[{
	DerInd,
	IndNumber,
	IneExp},

	IndNumber=InputTensorHead;
	IndNumber//=IndexFree;
	IndNumber//=FromIndexFree;
	IndNumber//=(List@@#)&;
	IndNumber//=Length;
	Table[
		Table[
			DerInd=(ToExpression/@Alphabet[])~Take~(-IndexNumber);
			IneExp=ToString@InputTensorHead<>
					ToString@PowerNumber<>
					ToString@IndexNumber;
			IneExp//=ToExpression;
			IneExp//=((#)@@(DerInd))&;
			DefTensor[IneExp,M3,
				PrintAs->(ToString@OptionValue@QuantitySymbol<>
					"("<>ToString@PowerNumber<>"|"<>
					ToString@IndexNumber<>")")];
			$RegisteredPowers@Head@IneExp={InputTensorHead,
				PowerNumber,IndexNumber};
		,
			{IndexNumber,IndNumber*PowerNumber,0,-2}
		];
	,
		{PowerNumber,1,$MaxPowerNumber}
	];
];
