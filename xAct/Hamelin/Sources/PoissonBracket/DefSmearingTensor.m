(*=====================*)
(*  DefSmearingTensor  *)
(*=====================*)

DefSmearingTensor[SmearingName_,Operand_]:=Module[{FreeIndices},
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@Operand));
	DefTensor[(Symbol@SmearingName)@@FreeIndices,M3];
	(Symbol@SmearingName)@@FreeIndices];
