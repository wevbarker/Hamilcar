(*================*)
(*  RegisterPair  *)
(*================*)

RegisteredFields={};
RegisteredMomenta={};
RegisterPair[FieldName_,MomentumName_]:=Module[{
	IndexedField=FromIndexFree@ToIndexFree@FieldName,
	Indices,
	IndexedMomentum},

	Indices=List@@IndexedField;
	IndexedMomentum=MomentumName@@(Minus/@Indices);
	RegisteredFields~AppendTo~IndexedField;
	RegisteredMomenta~AppendTo~IndexedMomentum;
];
