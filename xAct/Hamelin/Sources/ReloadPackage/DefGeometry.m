(*===============*)
(*  DefGeometry  *)
(*===============*)

DefManifold[M3,3,IndexRange[{a,z}]];
GSymb="\[ScriptG]";
(*Quiet@DefMetric[1,G[-a,-b],CD,{";","\!\(\*OverscriptBox[\(\[Del]\),\(_\)]\)"},*)
Quiet@DefMetric[1,G[-a,-b],CD,{";","\[Del]"},
	PrintAs->GSymb,SymCovDQ->True];
DefCovD[CDT[-a],SymbolOfCovD->{"#","D"},FromMetric->G];
DefTensor[TraceChristoffelCD[-c],M3,PrintAs->"\[CapitalGamma]"];
$ExpandTraceChristoffelCD=MakeRule[{TraceChristoffelCD[-c],ChristoffelCD[z,-z,-c]},MetricOn->All,ContractMetrics->True];
DefConstantSymbol[Pr,PrintAs->"\[ScriptW]"];

StandardIndices=ToString/@Alphabet[];
(*StandardIndicesSymb=(ToString@#)&/@Evaluate@((#[[2]])&/@{	
	{a,"\(\*OverscriptBox[\(\[Alpha]\),\(_\)]\)"},
	{b,"\(\*OverscriptBox[\(\[Beta]\),\(_\)]\)"},
	{c,"\(\*OverscriptBox[\(\[Chi]\),\(_\)]\)"},
	{d,"\(\*OverscriptBox[\(\[Delta]\),\(_\)]\)"},
	{e,"\(\*OverscriptBox[\(\[Epsilon]\),\(_\)]\)"},
	{f,"\(\*OverscriptBox[\(\[Phi]\),\(_\)]\)"},
	{g,"\(\*OverscriptBox[\(\[Gamma]\),\(_\)]\)"},
	{h,"\(\*OverscriptBox[\(\[Eta]\),\(_\)]\)"},
	{i,"\(\*OverscriptBox[\(\[Iota]\),\(_\)]\)"},
	{j,"\(\*OverscriptBox[\(\[Theta]\),\(_\)]\)"},
	{k,"\(\*OverscriptBox[\(\[Kappa]\),\(_\)]\)"},
	{l,"\(\*OverscriptBox[\(\[Lambda]\),\(_\)]\)"},
	{m,"\(\*OverscriptBox[\(\[Mu]\),\(_\)]\)"},
	{n,"\(\*OverscriptBox[\(\[Nu]\),\(_\)]\)"},
	{o,"\(\*OverscriptBox[\(\[Omicron]\),\(_\)]\)"},
	{p,"\(\*OverscriptBox[\(\[Pi]\),\(_\)]\)"},
	{q,"\(\*OverscriptBox[\(\[Omega]\),\(_\)]\)"},
	{r,"\(\*OverscriptBox[\(\[Rho]\),\(_\)]\)"},
	{s,"\(\*OverscriptBox[\(\[Sigma]\),\(_\)]\)"},
	{t,"\(\*OverscriptBox[\(\[Tau]\),\(_\)]\)"},
	{u,"\(\*OverscriptBox[\(\[Upsilon]\),\(_\)]\)"},
	{v,"\(\*OverscriptBox[\(\[Psi]\),\(_\)]\)"},
	{w,"\(\*OverscriptBox[\(\[Omega]\),\(_\)]\)"},
	{x,"\(\*OverscriptBox[\(\[Xi]\),\(_\)]\)"},
	{y,"\(\*OverscriptBox[\(\[CurlyPhi]\),\(_\)]\)"},
	{z,"\(\*OverscriptBox[\(\[Zeta]\),\(_\)]\)"}});*)

StandardIndicesSymb=(ToString@#)&/@Evaluate@((#[[2]])&/@{	
	{a,"\[ScriptA]"},{b,"\[ScriptB]"},{c,"\[ScriptC]"},{d,"\[ScriptD]"},{e,"\[ScriptE]"},{f,"\[ScriptF]"},{g,"\[ScriptG]"},{h,"\[ScriptH]"},{i,"\[ScriptI]"},{j,"\[ScriptJ]"},{k,"\[ScriptK]"},{l,"\[ScriptL]"},{m,"\[ScriptM]"},{n,"\[ScriptN]"},{o,"\[ScriptO]"},{p,"\[ScriptP]"},{q,"\[ScriptQ]"},{r,"\[ScriptR]"},{s,"\[ScriptS]"},{t,"\[ScriptT]"},{u,"\[ScriptU]"},{v,"\[ScriptV]"},{w,"\[ScriptW]"},{x,"\[ScriptX]"},{y,"\[ScriptY]"},{z,"\[ScriptZ]"}});

(PrintAs@Evaluate@#1^=Evaluate@#2)&~MapThread~{ToExpression/@StandardIndices,
	StandardIndicesSymb};

DefTensor[ConjugateMomentumG[-a,-b],M3,Symmetric[{-a,-b}],PrintAs->"\[Pi]"];
(*xAct`Hamelin`Private`DefInert@ConjugateMomentumG;*)
(*G~xAct`Hamelin`Private`RegisterPair~ConjugateMomentumG;*)
DefTensor[PseudoDeltaOne[],M3,PrintAs->"\[Delta]"];
DefTensor[PseudoDeltaTwo[],M3,PrintAs->"\[Delta]"];

(*DefTensor[SmearingOneTensor[AnyIndices@TangentM3],M3,PrintAs->"\[Alpha]"];
DefTensor[SmearingTwoTensor[AnyIndices@TangentM3],M3,PrintAs->"\[Beta]"];*)
