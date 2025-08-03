(*=============*)
(*  Hamilcar  *)
(*=============*)

(*===========*)
(*  Version  *)
(*===========*)

(*xAct`Hamelin`$Version={"0.0.0",{2023,11,4}};*)
xAct`Hamilcar`$Version={"0.0.0-developer",DateList@FileDate@$InputFileName~Drop~(-3)};

If[Unevaluated[xAct`xCore`Private`$LastPackage]===xAct`xCore`Private`$LastPackage,xAct`xCore`Private`$LastPackage="xAct`Hamilcar`"];

(* here is an error-killing line, I can't quite remember why we needed it! *)
Off@(Solve::fulldim);
Off@(Syntax::stresc);
Off@(FrontEndObject::notavail);

(*==================*)
(*  xAct`Hamilcar`  *)
(*==================*)

BeginPackage["xAct`Hamilcar`",{"xAct`xTensor`","xAct`SymManipulator`","xAct`xPerm`","xAct`xCore`","xAct`xTras`"}];
SetOptions[$FrontEndSession,EvaluationCompletionAction->"ScrollToOutput"];
Print[xAct`xCore`Private`bars];
Print["Package xAct`Hamilcar` version ",$Version[[1]],", ",$Version[[2]]];
Print["CopyRight \[Copyright] 2023, Will Barker, Drazen Glavan and Tom Zlosnik, under the General Public License."];
Print@" ** Von einem Pfeiffer verfürt und verloren.";

If[$FrontEnd==Null,
	xAct`Hamilcar`Private`$CLI=True,
	xAct`Hamilcar`Private`$CLI=False,
	xAct`Hamilcar`Private`$CLI=False];
Quiet@If[xAct`Hamilcar`Private`$CLI,
	xAct`Hamilcar`Private`$WorkingDirectory=Directory[],
	SetOptions[$FrontEndSession,EvaluationCompletionAction->"ScrollToOutput"];
	If[NotebookDirectory[]==$Failed,
		xAct`Hamilcar`Private`$WorkingDirectory=Directory[],
		xAct`Hamilcar`Private`$WorkingDirectory=NotebookDirectory[],
		xAct`Hamilcar`Private`$WorkingDirectory=NotebookDirectory[]]];
$Path~AppendTo~xAct`Hamilcar`Private`$WorkingDirectory;
xAct`Hamilcar`Private`$InstallDirectory=Select[FileNameJoin[{#,"xAct/Hamilcar"}]&/@$Path,DirectoryQ][[1]];

(*==============*)
(*  Disclaimer  *)
(*==============*)

If[xAct`xCore`Private`$LastPackage==="xAct`Hamilcar`",
Unset[xAct`xCore`Private`$LastPackage];
Print[xAct`xCore`Private`bars];
Print["These packages come with ABSOLUTELY NO WARRANTY; for details type Disclaimer[]. This is free software, and you are welcome to redistribute it under certain conditions. See the General Public License for details."];
Print[xAct`xCore`Private`bars]];

(*============================*)
(*  Declaration of functions  *)
(*============================*)

DefCanonicalField::usage="DefCanonicalField";
PoissonBracket::usage="PoissonBracket";
FindAlgebra::usage="FindAlgebra";
TotalFrom::usage="TotalFrom";
TotalTo::usage="TotalTo";
PrependTotalFrom::usage="PrependTotalFrom";
PrependTotalTo::usage="PrependTotalTo";
DefTimeTensor::usage="DefTimeTensor";
TimeD::usage="TimeD";

(*===========================*)
(*  Declaration of geometry  *)
(*===========================*)

M3::usage="M3 is the three-dimensional Lorentzian spacetime manifold.";
Time::usage="Time is the time coordinate orthogonal to M3.";
G::usage="G[-a,-b] is the spatial metric on M3.";
GTime::usage="GTime[-a,-b] is the time-dependent spatial metric on M3.";
GTimeInverse::usage="GTimeInverse[a,b] is the inverse of the time-dependent spatial metric on M3.";
ConjugateMomentumG::usage="ConjugateMomentumG[a,b] is the momentum conjugate to the spatial metric on M3.";
CD::usage="CD[-a] is the covariant derivative on M3.";

(*====================*)
(*  Global variables  *)
(*====================*)

$DynamicalMetric::usage="$DynamicalMetric is a global variable that determines whether the spatial metric is dynamical or not. Default is True.";
$DynamicalMetric=True;
$ManualSmearing=False;

Begin["xAct`Hamilcar`Private`"];
$MaxDerOrd=5;
$RegisteredFields={};
$RegisteredMomenta={};
$RegisteredTensorMomenta={};
$FromInert={};
$ToInert={};
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
	"PoissonBracket.m",
	"RulesTotal.m",
	"FindAlgebra.m",
	"TimeD.m"};On@Syntax::stresc;);
RereadSources[];
ToInertRules={};
FromInertRules={};
Begin["xAct`Hamilcar`"];
	xAct`Hamilcar`Private`ReloadPackage[];
	Quiet@If[$FrontEnd==Null,
		xAct`Hamilcar`Private`$CLI=True,
		xAct`Hamilcar`Private`$CLI=False,
		xAct`Hamilcar`Private`$CLI=False];
	$DefInfoQ=False;
End[];
End[];
EndPackage[];
