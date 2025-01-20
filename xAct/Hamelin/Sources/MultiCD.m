(*===========*)
(*  MultiCD  *)
(*===========*)

MultiCD[Inds___][InputExpr_]:=Module[{
	DerExp=InputExpr,
	DerInd=List@Inds},
	
	(DerExp//=CD[#])&/@(Reverse@DerInd);
DerExp];
