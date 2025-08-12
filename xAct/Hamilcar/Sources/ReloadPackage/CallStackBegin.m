(*==================*)
(*  CallStackBegin  *)
(*==================*)

$CallStackTrace=False;
CallStackBegin[]:=Module[{},
	$CallStackTrace=True;
	If[$CallStackTrace,
		DeleteFile[$CallStackTraceFileName];	
		$StackStream=List@OpenWrite[$CallStackTraceFileName,PageWidth->1000];
	];
];