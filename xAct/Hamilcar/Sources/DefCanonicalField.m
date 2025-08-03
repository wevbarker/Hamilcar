(*=====================*)
(*  DefCanonicalField  *)
(*=====================*)

IncludeHeader@"DefInert";
IncludeHeader@"RegisterPair";

$DefInfoQ=False;
Unprotect@AutomaticRules;
Options[AutomaticRules]={Verbose->False};
Protect@AutomaticRules;

Options@DefCanonicalField={
	Dagger->Real,	
	FieldSymbol->"\[ScriptQ]",
	MomentumSymbol->"\[ScriptP]"
};

DefCanonicalField[FieldName_[Inds___],Opts___?OptionQ]:=DefCanonicalField[FieldName[Inds],GenSet[],Opts];

DefCanonicalField[FieldName_[Inds___],SymmExpr_,OptionsPattern[]]:=Module[{
	MomentumName=ToExpression@("ConjugateMomentum"<>(ToString@FieldName)),
	TensorMomentumName=ToExpression@("TensorConjugateMomentum"<>(ToString@FieldName)),
	FieldSymbolValue=OptionValue@FieldSymbol,
	NewSymmExpr,
	MomentumSymbolValue=OptionValue@MomentumSymbol,
	TensorMomentumSymbolValue="\[GothicCapitalT]"<>ToString@OptionValue@MomentumSymbol,
	DaggerValue=OptionValue@Dagger},
	
	DefTimeTensor[
		FieldName@Inds,M3,SymmExpr,PrintAs->FieldSymbolValue,Dagger->DaggerValue];	
	DefInert@FieldName;	
	NewSymmExpr=SymmExpr/.{SomeIndex_?TangentM3`Q->-SomeIndex};
	DefTimeTensor[
		MomentumName@@({Inds}/.{SomeIndex_?TangentM3`Q->-SomeIndex}),M3,NewSymmExpr,PrintAs->MomentumSymbolValue,Dagger->DaggerValue];
	DefTensor[
		TensorMomentumName@@({Inds}/.{SomeIndex_?TangentM3`Q->-SomeIndex}),M3,NewSymmExpr,PrintAs->TensorMomentumSymbolValue,Dagger->DaggerValue];
	DefInert@MomentumName;	
	RegisterPair[FieldName,MomentumName,TensorMomentumName];
];
