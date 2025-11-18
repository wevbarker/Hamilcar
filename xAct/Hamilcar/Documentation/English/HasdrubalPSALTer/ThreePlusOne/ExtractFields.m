(*=================*)
(*  ExtractFields  *)
(*=================*)

ExtractFields[InputExpr_]:=Module[{Expr=InputExpr},
	Expr=Expr/.{Plus->List};
	(!(ListQ@Expr))~If~(Expr//=List);
	Expr//=ToIndexFree;
	Expr=Expr/.{CD->Identity,IndexFree->Identity};
	Expr//=Flatten;
	Expr=Expr.Table[0.1*Exp@ii,{ii,Length@Expr}];
	Expr//=Variables;	
	Expr//=DeleteDuplicates;
	Expr=DeleteElements[Expr,{epsilonG}];
	LagrangianCouplingsValue=DeleteCases[Expr,_?xTensorQ];
	Expr=Expr~DeleteElements~LagrangianCouplingsValue;
	Expr=ToString/@Expr;
	Expr=("xAct`PSALTer`"<>#<>"`")&/@Expr;
Expr];
