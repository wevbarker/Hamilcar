(*==============*)
(*  RulesTotal  *)
(*==============*)

IncludeHeader@"Recanonicalize";

TotalFrom[InputExpr_]~Y~Module[{Expr=InputExpr},
	(Expr=Expr/.#;Expr//=Recanonicalize;)&/@$FromRulesTotal;
Expr];
TotalTo[InputExpr_]~Y~Module[{Expr=InputExpr},
	(Expr=Expr/.#;Expr//=Recanonicalize)&/@$ToRulesTotal;
Expr];
PrependTotalFrom[InputRule_]~Y~($FromRulesTotal~PrependTo~InputRule);
PrependTotalTo[InputRule_]~Y~($ToRulesTotal~PrependTo~InputRule);
