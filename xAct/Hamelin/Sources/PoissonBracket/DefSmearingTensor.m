(*=====================*)
(*  DefSmearingTensor  *)
(*=====================*)

DefSmearingOneTensor[InputSmearing_,InputOperand_]:=Module[{FreeIndices},
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	DefTensor[((Symbol@InputSmearing)@@FreeIndices),M3,PrintAs->"\[Alpha]"];
(Symbol@InputSmearing)@@FreeIndices];

DefSmearingTwoTensor[InputSmearing_,InputOperand_]:=Module[{FreeIndices},
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	DefTensor[((Symbol@InputSmearing)@@FreeIndices),M3,PrintAs->"\[Beta]"];
(Symbol@InputSmearing)@@FreeIndices];
