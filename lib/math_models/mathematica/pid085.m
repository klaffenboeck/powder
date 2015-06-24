#!/usr/local/bin/MathematicaScript -script

aHex = ToExpression[$ScriptCommandLine[[2]]];
cHex = ToExpression[$ScriptCommandLine[[3]]];
gamma1 = ToExpression[$ScriptCommandLine[[4]]];
frac1 = ToExpression[$ScriptCommandLine[[5]]];
zoff1 = ToExpression[$ScriptCommandLine[[6]]];
zoff2 = ToExpression[$ScriptCommandLine[[7]]];
gamPID1 = ToExpression[$ScriptCommandLine[[8]]];
gamPID2 = ToExpression[$ScriptCommandLine[[9]]];
strain = ToExpression[$ScriptCommandLine[[10]]];
dev = ToExpression[$ScriptCommandLine[[11]]];
voi = ToExpression[$ScriptCommandLine[[12]]];
scale = ToExpression[$ScriptCommandLine[[13]]] / 1000000;

(*gamma1 = ToExpression[$ScriptCommandLine[[2]]];
gamPID1 = ToExpression[$ScriptCommandLine[[3]]];
occ = ToExpression[$ScriptCommandLine[[4]]];
zoff1 = ToExpression[$ScriptCommandLine[[5]]];
gamPID2 = ToExpression[$ScriptCommandLine[[6]]];
frac1 = ToExpression[$ScriptCommandLine[[7]]];
zoff2 = ToExpression[$ScriptCommandLine[[8]]];
aHex = ToExpression[$ScriptCommandLine[[9]]];
cHex = ToExpression[$ScriptCommandLine[[10]]];
scale = ToExpression[$ScriptCommandLine[[11]]]; *)
(*qVal = ToExpression[$ScriptCommandLine[[12]]];*)

list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

pidTPPdata = Import["pidfiles/PID085_xrd.csv","CSV"];
pidTPPdata = Table[{pidTPPdata[[ii]][[1]], pidTPPdata[[ii]][[2]]}, {ii, 1, 
   Length[pidTPPdata]}];
   
Get["PowderPackage.m" , Path->{"packages"}];
SetupPowder["/home/chuck/powder/lib/math_models/mathematica/packages"];
(*Print[mono];*)
(*sampled = SamplePowderXRDfunctionInvSymm[pidTPPdata, angle1, angPID1, occ, zoff1, angPID2, frac1, zoff2, 11.49, 10.046, 6000., strain, scale, 0.003, voigt, 0.09, 1.6, 0.388, 0.277, 0.569, 2.01, 3.0, 1.75, 0.6, 120., mono, 0.0];*)
(*four = fourParameterFunction[angle1, angPID1, occ, zoff1, angPID2, frac1];*)
(*Export["sampled.json",sampled]
nineParameterFunction[gamma1, gamPID1, occ, zoff1, gamPID2, frac1, zoff2, aHex, cHex, scale, qVal];*)
retval = SampleTwelveParamFunction[pidTPPdata,gamma1, gamPID1, strain, zoff1, gamPID2, frac1, zoff2, aHex, cHex, dev, voi, scale];
Print[retval];
Export["sampled.json",retval];
