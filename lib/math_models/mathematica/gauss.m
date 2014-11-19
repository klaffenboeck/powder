#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script

var = ToExpression[Rest[$ScriptCommandLine]];

Print[RandomVariate[MixtureDistribution @@ Transpose[{#[[1]], NormalDistribution[#[[2]], #[[3]]]}& /@ Partition[Rest[var], 3]], First[var]]];