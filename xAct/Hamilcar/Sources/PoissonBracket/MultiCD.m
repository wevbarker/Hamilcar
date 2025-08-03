(*===========*)
(*  MultiCD  *)
(*===========*)

MultiCD[Inds___][InputExpr_]:=Module[{
	Expr=InputExpr},	
	(Expr//=CD[#])&/@(Reverse@List@Inds);
Expr];
