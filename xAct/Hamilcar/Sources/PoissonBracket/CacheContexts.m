(*=================*)
(*  CacheContexts  *)
(*=================*)

CacheContexts[]:=Module[{NewContextList={
	"Global`",
	"xAct`Hamilcar`",
	"xAct`Hamilcar`Private`",
	"xAct`xTensor`",
	"xAct`xTensor`Private`",
	"xAct`xCore`",
	"xAct`xPerm`",
	"xAct`SymManipulator`",
	"TangentM3`"},
	LoadContexts,
	NewContextFileList},

	NewContextFileList=Module[{FileName=CreateFile[]},
		DumpSave[FileName,#];FileName]&/@NewContextList;

	$KernelsLaunched=False;
	While[!$KernelsLaunched,
		TimeConstrained[
			CloseKernels[];
			Off[LaunchKernels::nodef];
			LaunchKernels[$ProcessorCount];
			On[LaunchKernels::nodef];

			LoadContexts=({NewContextFileList}~NewParallelSubmit~(Off@(RuleDelayed::rhs);Get/@NewContextFileList;On@(RuleDelayed::rhs);))~Table~{TheKernel,$KernelCount};
			LoadContexts//=MonitorParallel;	
			DeleteFile/@NewContextFileList;
			$KernelsLaunched=True;
		,
			360
		];
	];
];

(* Function to check if contexts are cached *)
ContextsCachedQ[] ~Y~ Module[{TestResult},
	(* Check if kernels exist *)
	If[Length[Kernels[]] == 0, Return[False]];
	
	(* Test if Hamilcar context exists on all kernels *)
	TestResult = ParallelEvaluate[
		MemberQ[$Packages, "xAct`Hamilcar`"]
	];
	And @@ TestResult
];
