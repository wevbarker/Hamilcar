(*===============*)
(*  Definitions  *)
(*===============*)

Comment@"Here is the metric tensor.";
Expr=G[-a,-b];
DisplayExpression@Expr;

Comment@"The parallel part of the fermionic vector.";
DefCanonicalField[A[-m],FieldSymbol->"\[ScriptCapitalZ]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(Z\)]\)"];
A[-m]//DisplayExpression;
Comment@"Momentum conjugate to parallel part of the fermionic vector.";
ConjugateMomentumA[m]//DisplayExpression;
Comment@"The perpendicular part of the fermionic vector.";
DefCanonicalField[APerp[],FieldSymbol->"\[ScriptCapitalZ]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(Z\)]\)"];
APerp[]//DisplayExpression;
Comment@"Momentum conjugate to the perpendicular part of the fermionic vector.";
ConjugateMomentumAPerp[]//DisplayExpression;

Comment@"The parallel part of the axial torsion.";
DefCanonicalField[B[-m],FieldSymbol->"\[ScriptCapitalT]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(T\)]\)"];
B[-m]//DisplayExpression;
Comment@"Momentum conjugate to parallel part of the axial torsion.";
ConjugateMomentumB[m]//DisplayExpression;
Comment@"The perpendicular part of the axial torsion.";
DefCanonicalField[BPerp[],FieldSymbol->"\[ScriptCapitalT]",MomentumSymbol->"\!\(\*SubscriptBox[\(\[Pi]\),\(T\)]\)"];
BPerp[]//DisplayExpression;
Comment@"Momentum conjugate to the perpendicular part of the axial torsion.";
ConjugateMomentumBPerp[]//DisplayExpression;

Comment@"The coupling constant.";
DefConstantSymbol[Coupling,PrintAs->"\[ScriptG]"];
Comment@"Define the potential function.";
DefScalarFunction[V,PrintAs->"\[ScriptCapitalV]"];
