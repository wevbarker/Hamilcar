(*================*)
(*  SmearOperand  *)
(*================*)

SmearOperand[InputOperand_,Side_]:=Module[{Expr,FreeIndices},	
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	(Side==Left)~If~(Expr=SmearingLeft@@FreeIndices);
	(Side==Right)~If~(Expr=SmearingRight@@FreeIndices);
	Expr*=InputOperand;
	Expr//=ReplaceDummies;
Expr];

SmearFactor[InputOperand_,Side_]:=Module[{Expr,FreeIndices},	
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	(Side==Left)~If~(Expr=SmearingLeft@@FreeIndices);
	(Side==Right)~If~(Expr=SmearingRight@@FreeIndices);
Expr];
