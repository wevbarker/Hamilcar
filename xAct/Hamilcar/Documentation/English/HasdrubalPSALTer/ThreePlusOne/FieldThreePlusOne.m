(*=====================*)
(*  FieldThreePlusOne  *)
(*=====================*)

FieldThreePlusOne[InputExpr_,FieldName_]:=Module[{Class,Expr=InputExpr},
	Class=FieldName;
	Class//=xAct`PSALTer`Private`FieldAssociation;
	Expr//=(#/.(Class@xAct`PSALTer`Private`FieldToFiducialField))&;
	Expr//=(Class@xAct`PSALTer`Private`DecomposeFields);
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
Expr];
