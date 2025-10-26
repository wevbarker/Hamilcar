# Agent Computation Failure Analysis

## Summary
The agent failed to compute most Poisson brackets involving the rank-3 tensor field `h[a,b,c]`. Out of 15 bracket computations:
- 12 timed out (60 second limit exceeded)
- 1 returned `$Aborted`
- 2 succeeded (the two scalar field brackets)

## Root Causes

### 1. Name Collision with Abstract Index
**Problem**: `h` is already used as an abstract index in xAct/Hamilcar.

**Evidence**:
```
Symbol h is already used as an abstract index.
```

This warning appeared when defining `DefCanonicalField[h[a,b,c], ...]`.

**Impact**: The system cannot distinguish between `h` as an index label vs `h` as a field name, causing canonicalization to fail.

### 2. Canonicalization Failures
**Problem**: The tensor `h[a,b,c]` cannot be canonicalized.

**Evidence**:
```
Unknown expression not canonicalized: h[a, b, c]
Unknown expression not canonicalized: VarD[ConjugateMomentumPhi1[], CD][h[a, b, c], SmearingOneanaey[]]
Unknown expression not canonicalized: VarD[h, CD][ConjugateMomentumh[z$12236, z$12237, z$12238], ...]
```

**Impact**: PoissonBracket relies heavily on canonicalization to:
- Simplify tensor expressions
- Apply symmetries
- Contract indices
- Evaluate variational derivatives

Without canonicalization, these operations hang or produce malformed expressions.

### 3. Computational Complexity
**Problem**: Rank-3 fully symmetric tensor has many components and symmetries.

**Calculation**:
- In 3D space, a fully symmetric rank-3 tensor has: (3+3-1 choose 3) = 10 independent components
- Each Poisson bracket involves variational derivatives
- With smearing functions, this creates very large intermediate expressions

**Evidence**: The two scalar field brackets completed quickly:
```
[13:29:47.778] RESULT: Times[Global`SmearingOnegqqta[], Global`SmearingTwofqmfo[]]
```

But all brackets involving `h[a,b,c]` either aborted or timed out.

## What Succeeded vs Failed

### Succeeded (2/15):
1. `PoissonBracket[Phi1[], ConjugateMomentumPhi1[]]` ✓
2. `PoissonBracket[Phi2[], ConjugateMomentumPhi2[]]` ✓

### Failed (13/15):
All brackets involving `h[a,b,c]`:
- `PoissonBracket[h[a,b,c], ConjugateMomentumh[a,b,c]]` → **$Aborted**
- `PoissonBracket[Phi1[], Phi2[]]` → **Timeout**
- `PoissonBracket[ConjugateMomentumPhi1[], ConjugateMomentumPhi2[]]` → **Timeout**
- All 10 cross-brackets between `h` and scalar fields → **Timeout**

## Recommended Fixes

### Immediate Fix
Use a different field name that doesn't conflict with abstract indices:
```mathematica
DefCanonicalField[BigH[a,b,c], FieldSymbol->"H", MomentumSymbol->"Π"]
```

Common safe names: `BigH`, `HField`, `HSym`, `Htensor`

### Agent Improvement
The agent should:
1. Know which symbols are reserved (abstract indices: a,b,c,d,i,j,k,l,m,n,h,...)
2. Suggest alternative names when user requests conflicting names
3. Catch the warning and inform the user before attempting computations

### Package Improvement
Hamilcar could:
1. Raise an error (not just warning) when field name conflicts with index
2. Automatically sanitize field names (e.g., prepend "Field" to conflicting names)
3. Provide better error messages about why canonicalization failed

## Testing Recommendation

To verify this diagnosis, retry with non-conflicting name:
```mathematica
DefCanonicalField[HSym[a,b,c], FieldSymbol->"H", MomentumSymbol->"Π"]
DefCanonicalField[Phi1[], FieldSymbol->"φ₁", MomentumSymbol->"π₁"]
DefCanonicalField[Phi2[], FieldSymbol->"φ₂", MomentumSymbol->"π₂"]
```

Then compute the same 15 Poisson brackets. Expected result: all should complete successfully (though rank-3 brackets may still be slow).
