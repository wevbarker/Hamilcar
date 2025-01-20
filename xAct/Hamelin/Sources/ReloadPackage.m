(*=================*)
(*  ReloadPackage  *)
(*=================*)

ReadAtRuntime@"DefGeometry";

ReloadPackage[]:=Module[{},
	If[$NotLoaded,
		DefGeometry[];
		Begin@"xAct`Hamelin`Private`";
			RereadSources[];
		End[];
		$NotLoaded=False;,Null,
		DefGeometry[];
		Begin@"xAct`Hamelin`Private`";
			RereadSources[];
		End[];
		$NotLoaded=False;
	];
];
