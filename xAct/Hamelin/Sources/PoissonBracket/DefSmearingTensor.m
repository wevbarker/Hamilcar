(*=====================*)
(*  DefSmearingTensor  *)
(*=====================*)

$SmearingSymbols={"\[Alpha]","\[Beta]"};
$SmearScalars=True;
DefSmearingOneTensor[InputSmearing_,InputOperand_]:=Module[{FreeIndices},
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	If[!$SmearScalars&&Length@FreeIndices==0,Return@1];
	DefTensor[((Symbol@InputSmearing)@@FreeIndices),M3,PrintAs->First@$SmearingSymbols];
(Symbol@InputSmearing)@@FreeIndices];

DefSmearingTwoTensor[InputSmearing_,InputOperand_]:=Module[{FreeIndices},
	FreeIndices=(-#)&/@(FindFreeIndices@(Evaluate@InputOperand));
	If[!$SmearScalars&&Length@FreeIndices==0,Return@1];
	DefTensor[((Symbol@InputSmearing)@@FreeIndices),M3,PrintAs->Last@$SmearingSymbols];
(Symbol@InputSmearing)@@FreeIndices];
