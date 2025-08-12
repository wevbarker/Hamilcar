(*================*)
(*  CLICallStack  *)
(*================*)

IncludeHeader@"Status";
IncludeHeader@"GUICallStack";

(*Do **not** use ~Y~ here*)
CLICallStack[]:=Module[{},
	(* Use explicit private context reference like PSALTer might be doing *)
	If[xAct`Hamilcar`Private`$CLI,
		Run@("echo -e \""<>Status@StringReplace[ToString@$CallStack,"`"->"\`"]<>"\"");
	];
];