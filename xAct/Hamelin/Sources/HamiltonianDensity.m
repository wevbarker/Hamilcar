(*======================*)
(*  HamiltonianDensity  *)
(*======================*)

HamiltonianDensity=(
	(1/2)*APerpMomentum[]^2
	-(1/2)*CD[-a]@A[a]*CD[-b]@A[b]
	+V[APerp[]^2-A[-a]*A[a]]
);

DisplayExpression@HamiltonianDensity;
