(*=====================*)
(*  DefCanonicalField  *)
(*=====================*)

IncludeHeader@"DefInert";
IncludeHeader@"RegisterPair";

Options@DefCanonicalField={
	Dagger->Real,	
	FieldSymbol->"\[ScriptQ]",
	MomentumSymbol->"\[ScriptP]"
};

DefCanonicalField[FieldName_[Inds___],Opts___?OptionQ]:=DefCanonicalField[FieldName[Inds],GenSet[],Opts];

DefCanonicalField[FieldName_[Inds___],SymmExpr_,OptionsPattern[]]:=Module[{
	MomentumName=ToExpression@("ConjugateMomentum"<>(ToString@FieldName)),
	FieldSymbolValue=OptionValue@FieldSymbol,
	MomentumSymbolValue=OptionValue@MomentumSymbol,
	DaggerValue=OptionValue@Dagger},
	
	DefTensor[
		FieldName[Inds],M3,SymmExpr,PrintAs->FieldSymbolValue,Dagger->DaggerValue];	
	DefInert@FieldName;	
	DefTensor[
		MomentumName[Inds],M3,SymmExpr,PrintAs->MomentumSymbolValue,Dagger->DaggerValue];
	DefInert@MomentumName;	
	FieldName~RegisterPair~MomentumName;
];
