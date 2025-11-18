(*====================*)
(*  HasdrubalPSALTer  *)
(*====================*)

<<xAct`PSALTer`;
<<xAct`xPlain`;

Comment@"We want to use PSALTer to generate a large catalogue of models."

Get@FileNameJoin[{"HasdrubalPSALTer","TimeD.m"}];
Get@FileNameJoin[{"HasdrubalPSALTer","ThreePlusOne.m"}];

Comment@"Set up the Maxwell Lagrangian.";
DefField[VectorField[a],PrintAs->"\[ScriptCapitalA]",PrintSourceAs->"\[ScriptCapitalJ]"];
Expr=VectorField[a];
Expr//DisplayExpression;
Expr=-(1/4)*(CD[a]@VectorField[b]-CD[b]@VectorField[a])*(CD[-a]@VectorField[-b]-CD[-b]@VectorField[-a]);
Expr//DisplayExpression;

Comment@"Perform automated processing.";
Expr//=ThreePlusOne;

Quit[];
