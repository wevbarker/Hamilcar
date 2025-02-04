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
	NewSymmExpr,
	MomentumSymbolValue=OptionValue@MomentumSymbol,
	DaggerValue=OptionValue@Dagger},
	
	DefTensor[
		FieldName@Inds,M3,SymmExpr,PrintAs->FieldSymbolValue,Dagger->DaggerValue];	
	DefInert@FieldName;	
	NewSymmExpr=SymmExpr/.{SomeIndex_?TangentM3`Q->-SomeIndex};
	NewSymmExpr//Print;
	DefTensor[
		MomentumName@@({Inds}/.{SomeIndex_?TangentM3`Q->-SomeIndex}),M3,NewSymmExpr,PrintAs->MomentumSymbolValue,Dagger->DaggerValue];
	DefInert@MomentumName;	
	FieldName~RegisterPair~MomentumName;
];
