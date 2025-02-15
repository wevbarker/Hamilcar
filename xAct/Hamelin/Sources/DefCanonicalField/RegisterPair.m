(*================*)
(*  RegisterPair  *)
(*================*)

RegisterPair[FieldName_,MomentumName_]:=Module[{
	IndexedField=FromIndexFree@ToIndexFree@FieldName,
	Indices,
	IndexedMomentum},

	$RegisteredFields~AppendTo~FromIndexFree@ToIndexFree@FieldName;

	Indices=List@@IndexedField;
	IndexedMomentum=MomentumName@@(Minus/@Indices);
	$RegisteredMomenta~AppendTo~IndexedMomentum;
];
