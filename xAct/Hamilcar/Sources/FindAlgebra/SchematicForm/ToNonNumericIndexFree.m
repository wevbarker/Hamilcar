(*=========================*)
(*  ToNonNumericIndexFree  *)
(*=========================*)

ToNonNumericIndexFree[InputExpr_]~Y~Module[{Expr=InputExpr},
	(*ConstantSymbolQ does seem defined in xAct*)
	Expr//=ToIndexFree;
	Expr//=Identity@@#&;
	Expr//=FactorList;
	Expr//=(Power@@#&/@#)&;
	Expr//=DeleteCases[#,_?NumericQ]&;
	Expr//=Times@@#&;
	Block[{CD},
		CD[AnyExpr_]:=DummyCD*AnyExpr;
		Expr//=FullSimplify;
	];
	Expr//=ToIndexFree;
Expr];
