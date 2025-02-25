(*===========*)
(*  Hamelin  *)
(*===========*)

(*===========*)
(*  Version  *)
(*===========*)

(*xAct`Hamelin`$Version={"0.0.0",{2023,11,4}};*)
xAct`Hamelin`$Version={"0.0.0-developer",DateList@FileDate@$InputFileName~Drop~(-3)};

If[Unevaluated[xAct`xCore`Private`$LastPackage]===xAct`xCore`Private`$LastPackage,xAct`xCore`Private`$LastPackage="xAct`Hamelin`"];

(* here is an error-killing line, I can't quite remember why we needed it! *)
Off@(Solve::fulldim);
Off@(Syntax::stresc);
Off@(FrontEndObject::notavail);

(*=================*)
(*  xAct`Hamelin`  *)
(*=================*)

BeginPackage["xAct`Hamelin`",{"xAct`xTensor`","xAct`SymManipulator`","xAct`xPerm`","xAct`xCore`","xAct`xTras`"}];
SetOptions[$FrontEndSession,EvaluationCompletionAction->"ScrollToOutput"];
Print[xAct`xCore`Private`bars];
Print["Package xAct`Hamelin` version ",$Version[[1]],", ",$Version[[2]]];
Print["CopyRight \[Copyright] 2023, Will Barker, Drazen Glavan and Tom Zlosnik, under the General Public License."];
Print@" ** Von einem Pfeiffer verfürt und verloren.";

If[$FrontEnd==Null,
	xAct`Hamelin`Private`$CLI=True,
	xAct`Hamelin`Private`$CLI=False,
	xAct`Hamelin`Private`$CLI=False];
Quiet@If[xAct`Hamelin`Private`$CLI,
	xAct`Hamelin`Private`$WorkingDirectory=Directory[],
	SetOptions[$FrontEndSession,EvaluationCompletionAction->"ScrollToOutput"];
	If[NotebookDirectory[]==$Failed,
		xAct`Hamelin`Private`$WorkingDirectory=Directory[],
		xAct`Hamelin`Private`$WorkingDirectory=NotebookDirectory[],
		xAct`Hamelin`Private`$WorkingDirectory=NotebookDirectory[]]];
$Path~AppendTo~xAct`Hamelin`Private`$WorkingDirectory;
xAct`Hamelin`Private`$InstallDirectory=Select[FileNameJoin[{#,"xAct/Hamelin"}]&/@$Path,DirectoryQ][[1]];

(*==============*)
(*  Disclaimer  *)
(*==============*)

If[xAct`xCore`Private`$LastPackage==="xAct`Hamelin`",
Unset[xAct`xCore`Private`$LastPackage];
Print[xAct`xCore`Private`bars];
Print["These packages come with ABSOLUTELY NO WARRANTY; for details type Disclaimer[]. This is free software, and you are welcome to redistribute it under certain conditions. See the General Public License for details."];
Print[xAct`xCore`Private`bars]];

(*============================*)
(*  Declaration of functions  *)
(*============================*)

DefCanonicalField::usage="DefCanonicalField";
PoissonBracket::usage="PoissonBracket";

(*===========================*)
(*  Declaration of geometry  *)
(*===========================*)

M3::usage="M3 is the three-dimensional Lorentzian spacetime manifold.";
G::usage="G[-a,-b] is the spatial metric on M3.";
ConjugateMomentumG::usage="ConjugateMomentumG[a,b] is the momentum conjugate to the spatial metric on M3.";
CD::usage="CD[-a] is the covariant derivative on M3.";

Begin["xAct`Hamelin`Private`"];
$Strip=True;
$MaxDerOrd=5;
$RegisteredFields={};
$RegisteredMomenta={};
IncludeHeader[FunctionName_]:=Module[{PathName},
	PathName=$InputFileName~StringDrop~(-2);
	PathName=FileNameJoin@{PathName,FunctionName<>".m"};
	PathName//=Get;
];
ReadAtRuntime[FunctionName_]:=Module[{PathName,FunctionSymbol=Symbol@FunctionName},
	PathName=$InputFileName~StringDrop~(-2);
	PathName=FileNameJoin@{PathName,FunctionName<>".m"};
	FunctionSymbol[]:=PathName//Get;
];
RereadSources[]:=(Off@Syntax::stresc;(Get@FileNameJoin@{$InstallDirectory,"Sources",#})&/@{
	"ReloadPackage.m",
	"DefCanonicalField.m",
	"PoissonBracket.m"};On@Syntax::stresc;);
RereadSources[];
ToInertRules={};
FromInertRules={};
Begin["xAct`Hamelin`"];
	xAct`Hamelin`Private`ReloadPackage[];
	Quiet@If[$FrontEnd==Null,
		xAct`Hamelin`Private`$CLI=True,
		xAct`Hamelin`Private`$CLI=False,
		xAct`Hamelin`Private`$CLI=False];
	$DefInfoQ=False;
End[];
End[];
EndPackage[];
