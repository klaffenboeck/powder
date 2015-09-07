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


list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

pidTPPdata = Import["pidfiles/PID071_July2014_xrd.csv","CSV"];
pidTPPdata = Table[{pidTPPdata[[ii]][[1]], pidTPPdata[[ii]][[2]]}, {ii, 1, 
   Length[pidTPPdata]}];
   
Get["PowderPackage.m" , Path->{"packages"}];
SetupPowder["/home/chuck/powder/lib/math_models/mathematica/packages"];

retval = SampleTwelveParamFunctionPID071[pidTPPdata,gamma1, gamPID1, strain, zoff1, gamPID2, frac1, zoff2, aHex, cHex, dev, voi, scale];
Print[retval];
Export["sampled.json",retval];
