(*===============*)
(*  DefGeometry  *)
(*===============*)
DefManifold[M3,3,IndexRange[{a,z}]];
(*GSymb="\[ScriptH]";*)
GSymb="\[Gamma]";
(*Quiet@DefMetric[1,G[-a,-b],CD,{";","\!\(\*OverscriptBox[\(\[Del]\),\(_\)]\)"},*)
(*Quiet@DefMetric[1,G[-a,-b],CD,{";","\[Del]"},*)
Quiet@DefMetric[1,G[-a,-b],CD,{";","\[ScriptCapitalD]"},
	PrintAs->GSymb,SymCovDQ->True];
(*PrintAs@Evaluate@DetG^="\[ScriptH]";*)
PrintAs@Evaluate@DetG^="\[Gamma]";
DefCovD[CDT[-a],SymbolOfCovD->{"#","D"},FromMetric->G];

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

(*Define the momentum conjugate to the metric on the foliation*)
DefTimeTensor[ConjugateMomentumG[a,b],M3,
	Symmetric[{a,b}],PrintAs->"\[Pi]"];
DefTensor[TensorConjugateMomentumG[a,b],M3,
	Symmetric[{a,b}],PrintAs->"\[GothicCapitalT]\[Pi]"];

(*Define the powers of these canonical fields*)
xAct`Hamilcar`Private`DefPower[G,
	(*xAct`Hamilcar`Private`QuantitySymbol->"\[ScriptH]"];*)
	xAct`Hamilcar`Private`QuantitySymbol->"\[Gamma]"];
xAct`Hamilcar`Private`DefPower[ConjugateMomentumG,
	xAct`Hamilcar`Private`QuantitySymbol->"\[Pi]"];

(*Define the time coordinate orthogonal to the foliation*)
DefConstantSymbol[Time,PrintAs->"\[ScriptT]"];
(*Define the time-dependent metric*)
DefTimeTensor[GTime[-a,-b],M3,
	Symmetric[{-a,-b}],PrintAs->GSymb];
(*Define the inverse of the time-dependent metric*)
DefTimeTensor[GTimeInverse[a,b],M3,
	Symmetric[{a,b}],PrintAs->"\[GothicH]"];
xAct`Hamilcar`Private`GToGTime=MakeRule[{G[-a,-b],GTime[-a,-b]},
	MetricOn->None,ContractMetrics->False];
xAct`Hamilcar`Private`GTimeToG=MakeRule[{GTime[-a,-b],G[-a,-b]},
	MetricOn->None,ContractMetrics->False];
xAct`Hamilcar`Private`GToGTimeInverse=MakeRule[{G[a,b],GTimeInverse[a,b]},
	MetricOn->All,ContractMetrics->True];
xAct`Hamilcar`Private`GTimeInverseToG=MakeRule[{GTimeInverse[a,b],G[a,b]},
	MetricOn->All,ContractMetrics->True];
AutomaticRules[GTimeInversep,
	MakeRule[{GTimeInversep[a,b],-GTimep[a,b]},
	MetricOn->All,ContractMetrics->True]];
(*Define a dummy covariant derivative for use in `FindAlgebra`*)
(*DefTensor[FloatingCD[-i],M3,PrintAs->"\[Del]"];*)
DefTensor[FloatingCD[-i],M3,PrintAs->"\[ScriptCapitalD]"];
(*Simplify the Riemann curvature tensor in three dimensions*)
(*AutomaticRules[RiemannCD,*)
(*RiemannCDToRicciCD=*)
AutomaticRules[RiemannCD,MakeRule[{RiemannCD[-r,-s,-m,-n],G[-r,-m]*RicciCD[-s,-n]-G[-r,-n]*RicciCD[-s,-m]-G[-s,-m]*RicciCD[-r,-n]+G[-s,-n]*RicciCD[-r,-m]-(1/2)*(G[-r,-m]*G[-s,-n]-G[-r,-n]*G[-s,-m])*RicciScalarCD[]},MetricOn->All,ContractMetrics->True]];(**)
(*Define a dummy constraint for `CollectConstraints`*)
DefTensor[DummyConstraint[AnyIndices@TangentM3],M3];
(*Define a dummy measure for use in `FindAlgebra`*)
DefTensor[Measure[],M3];
(*Define a dummy reciprocal for use in `FindAlgebra`*)
DefTensor[GeneralReciprocal[],M3];
(*Define a collection of parameters for the boundary ansatz*)
DefConstantSymbol[ToExpression["s"<>ToString[i]]]~Table~{i,1,1000};
$AnsatzCoefficients=ToExpression["s"<>ToString[i]]~Table~{i,1,1000};
(*Initialize the rules for abbreviations*)
$FromRulesTotal={DummyVar->DummyVar};
$ToRulesTotal={DummyVar->DummyVar};
