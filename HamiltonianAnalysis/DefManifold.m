(*===============*)
(*  DefManifold  *)
(*===============*)

Comment@"We will set up a four-dimensional manifold.";
DefManifold[M3,3,IndexRange[{a,z}]];

Comment@"We will set up a flat metric and a derivative which we take to be the partial derivative.";
GSymb="\[Eta]";
DefMetric[1,G[-a,-b],CD,{",","\[PartialD]"},PrintAs->GSymb,SymCovDQ->True,FlatMetric->True];
