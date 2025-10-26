(* Reference script: Define scalar field and compute canonical bracket *)

<< xAct`Hamilcar`

(* Define scalar field exactly as agent should *)
DefCanonicalField[Phi[], FieldSymbol->"phi", MomentumSymbol->"pi"]

(* Compute bracket and store in variable *)
bracketResult = PoissonBracket[Phi[], ConjugateMomentumPhi[]]

(* Export kernel state for verification *)
Print["FIELD_EXISTS:", Head[Phi[]] =!= Symbol]
Print["MOMENTUM_EXISTS:", Head[ConjugateMomentumPhi[]] =!= Symbol]
Print["BRACKET_RESULT:", bracketResult]
Print["BRACKET_TYPE:", Head[bracketResult]]

Quit[];
