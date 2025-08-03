(*=========*)
(*  SemiD  *)
(*=========*)

SemiD[Inds___][InputOperand_,DerOrd_,InputTensor_]:=Module[{
	InputTensorHead=Head@InputTensor,
	FreInd=List@Inds,
	TenInd,
	DerInd,
	IneExp,
	DerExp=InputOperand},

	TenInd=InputTensor/.{InputTensorHead->List};
	DerInd=(ToExpression/@(Alphabet[]~RotateLeft~13))~Take~(-(DerOrd-Length@FreInd));
	IneExp=("CD"~StringRepeat~DerOrd)<>ToString@InputTensorHead;
	IneExp//=ToExpression;
	IneExp//=((#)@@(DerInd~Join~(Minus/@FreInd)~Join~TenInd))&;
	DerExp//=VarD[IneExp,CD];	
	(DerExp//=CD[#])&/@(Reverse@DerInd);
	DerExp*=(-1)^DerOrd;
	DerExp//=ReplaceDummies;
DerExp];
