(*==============*)
(*  RulesTotal  *)
(*==============*)

IncludeHeader@"Recanonicalize";

TotalFrom[InputExpr_]:=Module[{Expr=InputExpr},
	(Expr=Expr/.#;Expr//=Recanonicalize;)&/@$FromRulesTotal;
Expr];
TotalTo[InputExpr_]:=Module[{Expr=InputExpr},
	(Expr=Expr/.#;Expr//=Recanonicalize)&/@$ToRulesTotal;
Expr];
PrependTotalFrom[InputRule_]:=$FromRulesTotal~PrependTo~InputRule;
PrependTotalTo[InputRule_]:=$ToRulesTotal~PrependTo~InputRule;
