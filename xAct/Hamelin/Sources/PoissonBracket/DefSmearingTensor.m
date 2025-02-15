(*=====================*)
(*  DefSmearingTensor  *)
(*=====================*)

DefSmearingTensor[InputSmearing_,InputOperand_]:=Module[{FreeIndices},
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	((Symbol@InputSmearing)@@FreeIndices)~DefTensor~M3;
(Symbol@InputSmearing)@@FreeIndices];
