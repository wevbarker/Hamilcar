(*===========*)
(*  MultiCD  *)
(*===========*)

MultiCD[Inds___][InputExpr_]~Y~Module[{
	Expr=InputExpr},	
	(Expr//=CD[#])&/@(Reverse@List@Inds);
Expr];
