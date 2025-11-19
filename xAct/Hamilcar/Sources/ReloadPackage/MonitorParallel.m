(*===================*)
(*  MonitorParallel  *)
(*===================*)

MonitorParallel[ParallelisedArray_]:=Module[{
	ParallelisedArrayValue},
	ParallelisedArrayValue=WaitAll@ParallelisedArray;
ParallelisedArrayValue];
