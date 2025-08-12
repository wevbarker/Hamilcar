(*=================*)
(*  ReloadPackage  *)
(*=================*)

ReadAtRuntime@"DefGeometry";
IncludeHeader@"NewParallelSubmit";
IncludeHeader@"MonitorParallel";
IncludeHeader@"StackSetDelayed";
IncludeHeader@"CallStackBegin";
IncludeHeader@"CallStackEnd";
IncludeHeader@"CLICallStack";

ReloadPackage[]:=Module[{},
	If[$NotLoaded,
		DefGeometry[];
		Begin@"xAct`Hamilcar`Private`";
			RereadSources[];
		End[];
		$NotLoaded=False;,Null,
		DefGeometry[];
		Begin@"xAct`Hamilcar`Private`";
			RereadSources[];
		End[];
		$NotLoaded=False;
	];
];
