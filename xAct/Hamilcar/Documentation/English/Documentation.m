<<xAct`xPlain`;
Title@"Hamilcar: A Mathematica Package for Canonical Field Theory";
Author@"Will E. V. Barker";

Comment@"This is the main documentation for the Hamilcar package, which extends xAct to perform canonical field theory calculations in a 3+1 dimensional spacetime decomposition.

Hamilcar is a software package for Wolfram (formerly Mathematica) designed to perform canonical field theory calculations in 3+1 dimensions. The canonical formulation assumes the action S to have the structure S = integral of dt integral of d cubed x [pi psi(x,t) dot psi(x,t) - H(psi,pi psi)], where the ingredients are:
- The dynamical fields psi(x,t) are real tensors on the spatial manifold, which may be a collection of distinct fields, each field having some collection of spatial indices (a, b, etc.), perhaps with some symmetry among the indices.
- The conjugate momenta pi psi(x,t) are the canonical momenta conjugate to the fields psi(x,t).  
- The Hamiltonian density H(psi,pi psi) is constructed from the fields, momenta, spatial metric, and spatial derivatives.

The package provides essential functions for canonical field theory:
- DefCanonicalField: defines canonical field pairs and their conjugate momenta
- PoissonBracket: computes Poisson brackets between operators using variational derivatives
- TotalFrom/TotalTo: expands expressions to canonical variables and converts back
- FindAlgebra: determines constraint algebra coefficients using ansatz expressions";

Section@"Introduction";
Comment@"Hamilcar provides tools for defining canonical field pairs, computing Poisson brackets, and analyzing constraint algebras in field theory.

Installation and Setup:
To install Hamilcar, use the provided installation script: ./install.sh which copies the xAct/Hamilcar directory to both ~/.Wolfram/Applications/xAct/ and ~/.Mathematica/Applications/xAct/ directories, excluding .mx files. In Mathematica, load the package with: <<xAct`Hamilcar`.

Pre-defined geometry:
When you first run <<xAct`Hamilcar` the software defines a three-dimensional spatial hypersurface with the ingredients: a, b, c, ..., z are spatial coordinate indices (corresponding to adapted coordinates in the ADM prescription); G[-a,-b] is the induced metric h ab on the spatial hypersurface; CD[-a]@ is the spatial covariant derivative nabla a; epsilonG[-a,-b,-c] is the induced totally antisymmetric tensor epsilon abc on the spatial hypersurface.

Key global variables:
- $DynamicalMetric: Controls whether spatial metric is treated as dynamical field (default: True)
- $ManualSmearing: When True, disables automatic smearing in Poisson brackets (default: False)
- $RegisteredFields: List of registered field tensors
- $RegisteredMomenta: List of registered momentum tensors";

Section@"General relativity";
Comment@"Canonical formulation of general relativity using the ADM decomposition.

This section demonstrates the ADM (Arnowitt-Deser-Misner) formulation of general relativity in canonical field theory. In the ADM formalism, spacetime is decomposed as 3+1 dimensional, with spatial slices evolving in time. The key variables are the spatial metric h ab and its conjugate momentum pi ab, related to the extrinsic curvature. The constraints are the super-Hamiltonian (Hamiltonian constraint) and super-momentum (momentum constraint) which generate time evolution and spatial diffeomorphisms respectively.";

Comment@"We first load the Hamilcar package, which provides tools for canonical field theory calculations. The package extends xAct to work with time-dependent fields and their conjugate momenta in a 3+1 dimensional spacetime decomposition.";
Code[<<xAct`Hamilcar`];

Comment@"Set some convenient options for xAct:";
SetOptions[$FrontEndSession,EvaluationCompletionAction->"ScrollToOutput"];
$DefInfoQ=False;
Unprotect@AutomaticRules;
Options[AutomaticRules]={Verbose->False};
Protect@AutomaticRules;

Comment@"Define some utility functions for working with expressions and Poisson brackets.

These utility functions help streamline the canonical field theory calculations by providing convenient ways to manipulate expressions, display results, and compute Poisson brackets with proper canonical processing (TotalFrom/TotalTo transformations).";

CompareExpressions[InputExpr1_,InputExpr2_]:=Module[{
	Expr,Expr1=InputExpr1,Expr2=InputExpr2},
	Comment@"Comparing...";
	Expr=Expr1-Expr2;
	Expr//=TotalFrom;
	Expr//=TotalFrom;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=CollectTensors;
	Expr//DisplayExpression;
Expr];

DisplayRule~SetAttributes~HoldAll;
DisplayRule[InputExpr_,InputRule_]:=Module[{Expr=Evaluate@InputExpr,EqnLabelValue=ToString@Defer@InputRule},
	EqnLabelValue//=StringDelete[#,"Defer["]&;
	EqnLabelValue//=StringDelete[#,"]"]&;
	Expr=Expr/.Evaluate@InputRule;
	Expr//=ToCanonical;
	Expr//=ContractMetric;
	Expr//=ScreenDollarIndices;
	Expr//=CollectTensors;
	Expr//=ScreenDollarIndices;
	Expr//=FullSimplify;
	DisplayExpression[(InputExpr->Expr),EqnLabel->EqnLabelValue];
Expr];

DisplayedPoissonBracket[LeftOperand_,RightOperand_]:=Module[{Expr},
	Expr={LeftOperand,RightOperand};
	Expr//DisplayExpression;
	Expr//=(TotalFrom/@#)&;
	Expr//=(PoissonBracket@@#)&;
	Expr//=TotalTo;
	Expr//DisplayExpression;
Expr];


Comment@"Verify the canonical Poisson bracket for the metric and its conjugate momentum. Define the trace of the conjugate momentum of the metric.

The spatial metric G[-a,-b] and its conjugate momentum ConjugateMomentumG[a,b] should satisfy the fundamental canonical Poisson bracket relations. These are the basic building blocks for all subsequent bracket calculations in the ADM formalism.";
Code[
DefTensor[TraceConjugateMomentumG[],M3,PrintAs->"\[Pi]"];
FromTraceConjugateMomentumG=MakeRule[{
	TraceConjugateMomentumG[],
	Scalar[ConjugateMomentumG[a,-a]]},
	MetricOn->All,ContractMetrics->True]
];
TraceConjugateMomentumG[]~DisplayRule~FromTraceConjugateMomentumG;
Comment@"Apply total derivative preprocessing to the trace rule.";
Code[FromTraceConjugateMomentumG//PrependTotalFrom];

Comment@"Test various index configurations for the induced metric and its conjugate momentum to verify canonical Poisson brackets.";
Perms={};
Perms//=(#~Join~Permutations@{1,1,1,1})&;
Perms//=(#~Join~Permutations@{1,1,1,-1})&;
Perms//=(#~Join~Permutations@{1,1,-1,-1})&;
Perms//=(#~Join~Permutations@{1,-1,-1,-1})&;
Perms//=(#~Join~Permutations@{-1,-1,-1,-1})&;
Indices=MapThread[Times,{{a,b,c,d},#}]&/@Perms;
AllConfigurations={G[#1,#2],ConjugateMomentumG[#3,#4]}&@@@Indices;
Module[{Expr,Answ},Expr=#;Answ=PoissonBracket@@#;DisplayExpression[Expr->Answ];]&/@AllConfigurations;

Comment@"Define the lapse function and shift vector of the ADM decomposition.

In the ADM formalism, the lapse function N and shift vector N i describe how the spatial slices are embedded in spacetime. The lapse controls the rate of proper time advance between slices, while the shift describes how the spatial coordinate system moves between slices. These are Lagrange multipliers that enforce the super-Hamiltonian and super-momentum constraints respectively.";
Code[DefTensor[Lapse[],M3,PrintAs->"\[ScriptCapitalN]"]];
Lapse[]//DisplayExpression;
Code[DefTensor[Shift[m],M3,PrintAs->"\[ScriptCapitalN]"]];
Shift[m]//DisplayExpression;


Comment@"Define the gravitational coupling constant.";
Code[DefConstantSymbol[GravitationalCoupling,PrintAs->"\[Alpha]"]];
GravitationalCoupling//DisplayExpression;

Comment@"Define the super-Hamiltonian constraint (Hamiltonian constraint) from the ADM formalism.";
Code[
DefTensor[SuperHamiltonian[],M3,PrintAs->"\[ScriptCapitalH]"];
FromSuperHamiltonian=MakeRule[{SuperHamiltonian[],
	(1/(GravitationalCoupling*Sqrt@DetG[]))*(
		ConjugateMomentumG[i,j]*ConjugateMomentumG[-i,-j]
		-(1/2)*TraceConjugateMomentumG[]^2
	)-GravitationalCoupling*Sqrt@DetG[]*RicciScalarCD[]},
	MetricOn->All,ContractMetrics->True]
];
SuperHamiltonian[]~DisplayRule~FromSuperHamiltonian;
Comment@"Apply total derivative preprocessing to the super-Hamiltonian rule.";
Code[FromSuperHamiltonian//PrependTotalFrom];

Comment@"Define the super-momentum constraint (momentum constraint) from the ADM formalism.";
Code[
DefTensor[SuperMomentum[-i],M3,PrintAs->"\[ScriptCapitalH]"];
FromSuperMomentum=MakeRule[{SuperMomentum[-i],
	-2*CD[-j]@ConjugateMomentumG[j,-i]},
	MetricOn->All,ContractMetrics->True]
];
SuperMomentum[-i]~DisplayRule~FromSuperMomentum;
Comment@"Apply total derivative preprocessing to the super-momentum rule.";
Code[FromSuperMomentum//PrependTotalFrom];


Comment@"Define smearing functions needed for computing Poisson brackets. These functions allow us to evaluate brackets between constraints at different spatial points.

Smearing functions are mathematical tools essential for computing Poisson brackets between field operators at different spatial points. In canonical field theory, constraints like the super-Hamiltonian and super-momentum are density-like objects that need to be integrated over spatial regions. Smearing functions provide the test functions for these integrations, allowing us to compute the algebra between smeared constraints. The scalar smearing functions are used with scalar constraints, while vector smearing functions are used with vector constraints like the super-momentum.";

Comment@"Define scalar smearing functions.";
Code[DefTensor[ScalarSmearingS[],M3,PrintAs->"\[ScriptS]"]];
ScalarSmearingS[]//DisplayExpression;
Code[DefTensor[ScalarSmearingF[],M3,PrintAs->"\[ScriptF]"]];
ScalarSmearingF[]//DisplayExpression;

Comment@"Define vector smearing functions with both covariant and contravariant versions.";
Code[DefTensor[VectorSmearingCovariantS[-i],M3,PrintAs->"\[ScriptS]"]];
VectorSmearingCovariantS[-i]//DisplayExpression;
Code[DefTensor[VectorSmearingContravariantS[i],M3,PrintAs->"\[ScriptS]"]];
VectorSmearingContravariantS[i]//DisplayExpression;
Code[DefTensor[VectorSmearingCovariantF[-i],M3,PrintAs->"\[ScriptF]"]];
VectorSmearingCovariantF[-i]//DisplayExpression;
Code[DefTensor[VectorSmearingContravariantF[i],M3,PrintAs->"\[ScriptF]"]];
VectorSmearingContravariantF[i]//DisplayExpression;



Comment@"Now we compute the algebra between constraints. This is the Dirac hypersurface deformation algebra of general relativity.

The Dirac hypersurface deformation algebra describes how the constraints of general relativity act on each other under Poisson brackets. This algebra shows that the super-Hamiltonian generates normal deformations of the spatial hypersurface, while the super-momentum generates tangential deformations (spatial diffeomorphisms). The algebra closes in the sense that brackets between constraints produce linear combinations of the same constraints, possibly with structure functions that depend on the smearing functions and their derivatives.";

Comment@"Set manual smearing to true so we can use our defined smearing functions.";
Code[$ManualSmearing=True];

Comment@"Compute the auto-commutator of the super-Hamiltonian using scalar smearing functions.";
Code[
Expr={ScalarSmearingF[]*SuperHamiltonian[],ScalarSmearingS[]*SuperHamiltonian[]}
];
Expr//DisplayExpression;
Code[
Expr//=(TotalFrom/@#)&;
Expr//=(PoissonBracket@@#)&;
Expr//=TotalTo;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"SuperHamiltonianSuperHamiltonianPoissonBracket"];

Comment@"Use FindAlgebra to express the bracket result in terms of the super-momentum constraint and spatial derivatives of the smearing functions.";
Code[
Expr//=TotalFrom;
Expr//=FindAlgebra[#,
	{SuperMomentum*CD@ScalarSmearingF*ScalarSmearingS,
	SuperMomentum*ScalarSmearingF*CD@ScalarSmearingS},
	{SuperHamiltonian[],
	SuperMomentum[i]}]&;
{BracketExpr,RulesExpr}=Expr
];
BracketExpr//DisplayExpression;

Comment@"Compute the bracket between the super-Hamiltonian and super-momentum using scalar and contravariant vector smearing.";
Code[
Expr={ScalarSmearingF[]*SuperHamiltonian[],VectorSmearingContravariantS[i]*SuperMomentum[-i]}
];
Expr//DisplayExpression;
Code[
Expr//=(TotalFrom/@#)&;
Expr//=(PoissonBracket@@#)&;
Expr//=TotalTo;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"SuperHamiltonianSuperMomentumPoissonBracket"];

Comment@"Use FindAlgebra to express this bracket in terms of the super-Hamiltonian constraint.";
Code[
Expr//=TotalFrom;
Expr//=FindAlgebra[#,
	{SuperHamiltonian*CD@ScalarSmearingF*VectorSmearingContravariantS,
	SuperHamiltonian*ScalarSmearingF*CD@VectorSmearingContravariantS},
	{SuperHamiltonian[],
	SuperMomentum[i]}]&;
{BracketExpr,RulesExpr}=Expr
];
BracketExpr//DisplayExpression;

Comment@"Compute the auto-commutator of the super-momentum using contravariant vector smearing.";
Code[
Expr={VectorSmearingContravariantF[i]*SuperMomentum[-i],VectorSmearingContravariantS[j]*SuperMomentum[-j]}
];
Expr//DisplayExpression;
Code[
Expr//=(TotalFrom/@#)&;
Expr//=(PoissonBracket@@#)&;
Expr//=TotalTo;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"SuperMomentumSuperMomentumPoissonBracket"];

Comment@"Use FindAlgebra to express this bracket in terms of the super-momentum constraint.";
Code[
Expr//=TotalFrom;
Expr//=FindAlgebra[#,
	{SuperMomentum*CD@VectorSmearingContravariantF*VectorSmearingContravariantS,
	SuperMomentum*VectorSmearingContravariantF*CD@VectorSmearingContravariantS},
	{SuperHamiltonian[],
	SuperMomentum[i]}]&;
{BracketExpr,RulesExpr}=Expr
];
BracketExpr//DisplayExpression;

Comment@"Compute the auto-commutator of the super-momentum using covariant vector smearing for comparison.";
Code[
Expr={VectorSmearingCovariantF[-i]*SuperMomentum[i],VectorSmearingCovariantS[-j]*SuperMomentum[j]}
];
Expr//DisplayExpression;
Code[
Expr//=(TotalFrom/@#)&;
Expr//=(PoissonBracket@@#)&;
Expr//=TotalTo;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"SuperMomentumSuperMomentumCovariantPoissonBracket"];

Comment@"Use FindAlgebra to express this bracket in terms of the super-momentum constraint with covariant smearing.";
Code[
Expr//=TotalFrom;
Expr//=FindAlgebra[#,
	{SuperMomentum*CD@VectorSmearingCovariantF*VectorSmearingCovariantS,
	SuperMomentum*VectorSmearingCovariantF*CD@VectorSmearingCovariantS},
	{SuperHamiltonian[],
	SuperMomentum[i]}]&;
{BracketExpr,RulesExpr}=Expr
];
BracketExpr//DisplayExpression;

Section@"Maxwell theory";
Comment@"Canonical electromagnetic field theory in the Hamiltonian formalism. Maxwell theory is simpler than GR since there are no metric variations in Poisson brackets.

This section demonstrates the canonical formulation of electromagnetic field theory (Maxwell theory). Unlike general relativity, Maxwell theory is formulated on a fixed background spacetime, making it conceptually simpler. The canonical variables are the spatial components of the vector potential A i and their conjugate momenta (the electric field components E i). The theory contains the Gauss constraint as a primary constraint arising from the absence of time derivatives of the temporal component A 0. The Dirac algorithm shows that no secondary constraints arise, confirming that the theory describes two transverse photon polarizations.";


Comment@"For Maxwell theory, we need to disable dynamical metric since we work on a fixed background and enable manual smearing for Maxwell theory calculations.";
Code[$DynamicalMetric=False];
Code[$ManualSmearing=True];


Comment@"Define the spatial components of the electromagnetic vector potential and their canonical conjugate momenta (the electric field components).

In the canonical formulation of electromagnetism, the spatial components of the vector potential A i serve as the canonical position variables, while their conjugate momenta are the electric field components E i. The temporal component A 0 does not have a conjugate momentum, making it a non-dynamical Lagrange multiplier that enforces the Gauss constraint.";
Code[DefCanonicalField[VectorPotential[-i],FieldSymbol->"A",MomentumSymbol->"E"]];
VectorPotential[-i]//DisplayExpression;
ConjugateMomentumVectorPotential[i]//DisplayExpression;

Comment@"Verify the canonical Poisson bracket between vector potential and electric field. Temporarily disable manual smearing for canonical bracket verification.";
Code[$ManualSmearing=False];
Code[
Expr={VectorPotential[-i],ConjugateMomentumVectorPotential[j]}
];
Expr//DisplayExpression;
Code[
Expr//=(PoissonBracket@@#)&;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"MaxwellCanonicalBracket"];
Comment@"Re-enable manual smearing for subsequent calculations.";
Code[$ManualSmearing=True];


Comment@"Define the magnetic field components as the curl of the vector potential.";
Code[
DefTensor[MagneticField[i],M3,PrintAs->"B"];
FromMagneticField=MakeRule[{MagneticField[i],
	epsilonG[i,j,k]*CD[-j]@VectorPotential[-k]},
	MetricOn->All,ContractMetrics->True]
];
MagneticField[i]~DisplayRule~FromMagneticField;
Comment@"Apply total derivative preprocessing to the magnetic field rule.";
Code[FromMagneticField//PrependTotalFrom];

Comment@"Define the Maxwell Hamiltonian as the integral of electric and magnetic energy densities.";
Code[
DefTensor[MaxwellHamiltonian[],M3,PrintAs->"H"];
FromMaxwellHamiltonian=MakeRule[{MaxwellHamiltonian[],
	(1/2)*(ConjugateMomentumVectorPotential[i]*ConjugateMomentumVectorPotential[-i] + MagneticField[i]*MagneticField[-i])},
	MetricOn->All,ContractMetrics->True]
];
MaxwellHamiltonian[]~DisplayRule~FromMaxwellHamiltonian;
Comment@"Apply total derivative preprocessing to the Maxwell Hamiltonian rule.";
Code[FromMaxwellHamiltonian//PrependTotalFrom];


Comment@"The temporal component of the vector potential is a Lagrange multiplier, leading to Gauss constraint as a primary constraint.

In electromagnetic theory, the temporal component A 0 of the four-vector potential does not appear with time derivatives in the Lagrangian, making it a non-dynamical variable (Lagrange multiplier). The Euler-Lagrange equation for A 0 gives the Gauss constraint, which states that the divergence of the electric field equals the charge density. In the absence of charges, this constraint takes the simple form divergence of E = 0.";
Code[
DefTensor[GaussConstraint[],M3,PrintAs->"G"];
FromGaussConstraint=MakeRule[{GaussConstraint[],
	CD[-i]@ConjugateMomentumVectorPotential[i]},
	MetricOn->All,ContractMetrics->True]
];
GaussConstraint[]~DisplayRule~FromGaussConstraint;
Comment@"Apply total derivative preprocessing to the Gauss constraint rule.";
Code[FromGaussConstraint//PrependTotalFrom];

Comment@"Define the Lagrange multiplier for Gauss constraint (the temporal component of the vector potential).";
Code[DefTensor[LagrangeMultiplierA0[],M3,PrintAs->"\!\(\*SubscriptBox[\(A\),\(0\)]\)"]];
LagrangeMultiplierA0[]//DisplayExpression;


Comment@"The total Hamiltonian includes the Maxwell Hamiltonian plus the Gauss constraint with its multiplier.

In constrained Hamiltonian systems, the total Hamiltonian is constructed by adding to the canonical Hamiltonian all primary constraints multiplied by their corresponding Lagrange multipliers. For Maxwell theory, this gives H T = H Maxwell + A 0 * G, where G is the Gauss constraint and A 0 is its Lagrange multiplier (the temporal component of the vector potential).";
Code[
DefTensor[MaxwellTotalHamiltonian[],M3,PrintAs->"\!\(\*SubscriptBox[\(H\),\(T\)]\)"];
FromMaxwellTotalHamiltonian=MakeRule[{MaxwellTotalHamiltonian[],
	MaxwellHamiltonian[] + LagrangeMultiplierA0[]*GaussConstraint[]},
	MetricOn->All,ContractMetrics->True]
];
MaxwellTotalHamiltonian[]~DisplayRule~FromMaxwellTotalHamiltonian;
Comment@"Apply total derivative preprocessing to the total Hamiltonian rule.";
Code[FromMaxwellTotalHamiltonian//PrependTotalFrom];


Comment@"Check if the Gauss constraint is preserved under time evolution by computing the Poisson bracket between the smeared constraint and the total Hamiltonian.

The consistency of a primary constraint under time evolution is checked by computing its Poisson bracket with the total Hamiltonian. If this bracket vanishes identically, the constraint is preserved and no secondary constraints arise. If the bracket is non-zero, it either gives a secondary constraint or determines a Lagrange multiplier. For the Gauss constraint in Maxwell theory, the bracket should vanish identically, confirming the consistency of the constraint system.";
Code[
Expr={ScalarSmearingF[]*GaussConstraint[],MaxwellTotalHamiltonian[]}
];
DisplayExpression[Expr,EqnLabel->"PrePoissonBracket"];
Code[
Expr//=(TotalFrom/@#)&;
Expr//=(PoissonBracket@@#)&;
Expr//=VarD[ScalarSmearingF[],CD];
Expr//=TotalFrom;
Expr//=TotalTo;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"GaussConstraintConsistency"];

Comment@"The result should vanish identically, showing that no secondary constraints arise. Taking the variational derivative with respect to the smearing function ScalarSmearingF[] demonstrates that the coefficient of any term must be zero.";

Comment@"Compute the Poisson bracket between Gauss constraints at different points using scalar smearing.";
Code[
Expr={ScalarSmearingF[]*GaussConstraint[],ScalarSmearingS[]*GaussConstraint[]}
];
Expr//DisplayExpression;
Code[
Expr//=(TotalFrom/@#)&;
Expr//=(PoissonBracket@@#)&;
Expr//=TotalTo;
Expr//=FullSimplify
];
DisplayExpression[Expr,EqnLabel->"GaussGaussConstraintAlgebra"];

Quit[];
