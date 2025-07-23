(*================*)
(*  RegisterPair  *)
(*================*)

RegisterPair[FieldName_,MomentumName_,TensorMomentumName_]:=Module[{
	IndexedField=FromIndexFree@ToIndexFree@FieldName,
	Indices,
	IndexedMomentum,
	IndexedTensorMomentum},

	$RegisteredFields~AppendTo~FromIndexFree@ToIndexFree@FieldName;

	Indices=List@@IndexedField;
	IndexedMomentum=MomentumName@@(Minus/@Indices);
	$RegisteredMomenta~AppendTo~IndexedMomentum;
	IndexedTensorMomentum=TensorMomentumName@@(Minus/@Indices);
	$RegisteredTensorMomenta~AppendTo~IndexedTensorMomentum;
];
