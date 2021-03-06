#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script

gamma1 = ToExpression[$ScriptCommandLine[[2]]];
gamPID1 = ToExpression[$ScriptCommandLine[[3]]];
occ = ToExpression[$ScriptCommandLine[[4]]];
zoff1 = ToExpression[$ScriptCommandLine[[5]]];
gamPID2 = ToExpression[$ScriptCommandLine[[6]]];
frac1 = ToExpression[$ScriptCommandLine[[7]]];
zoff2 = ToExpression[$ScriptCommandLine[[8]]];
aHex = ToExpression[$ScriptCommandLine[[9]]];
cHex = ToExpression[$ScriptCommandLine[[10]]];
(*scale = ToExpression[$ScriptCommandLine[[11]]];
qVal = ToExpression[$ScriptCommandLine[[12]]];*)

list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

pidTPPdata = Import["packages/pidTPPdata.csv","CSV"];
pidTPPdata = Table[{pidTPPdata[[ii]][[1]], pidTPPdata[[ii]][[2]]}, {ii, 1, 
   Length[pidTPPdata]}];
   Print[pidTPPdata];
Get["PowderPackage.m" , Path->{"packages"}];
SetupPowder["/Users/HappyMandi/Desktop/Programming/ror/Powder/lib/mathematica/packages"];
Print[mono];
(*sampled = SamplePowderXRDfunctionInvSymm[pidTPPdata, angle1, angPID1, occ, zoff1, angPID2, frac1, zoff2, 11.49, 10.046, 6000., strain, scale, 0.003, voigt, 0.09, 1.6, 0.388, 0.277, 0.569, 2.01, 3.0, 1.75, 0.6, 120., mono, 0.0];*)
(*four = fourParameterFunction[angle1, angPID1, occ, zoff1, angPID2, frac1];*)
(*Export["sampled.json",sampled]
nineParameterFunction[gamma1, gamPID1, occ, zoff1, gamPID2, frac1, zoff2, aHex, cHex, scale, qVal];*)
retval = SampleNineParamFunction[pidTPPdata,gamma1, gamPID1, occ, zoff1, gamPID2, frac1, zoff2, aHex, cHex, 0.000006313];
Export["sampled.json",retval];

