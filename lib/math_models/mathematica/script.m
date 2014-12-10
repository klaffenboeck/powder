#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script
(*Print[$ScriptCommandLine[[3]]];*)
param1 = ToExpression[$ScriptCommandLine[[2]]];
param2 = ToExpression[$ScriptCommandLine[[3]]];
param3 = ToExpression[$ScriptCommandLine[[4]]];
param4 = ToExpression[$ScriptCommandLine[[5]]];
list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];
(*tppAtomXYZpositions = Partition[list, 3];
tppAtomTypes = ReadList["ExampleData/tppAtomTypes", Record, RecordSeparators -> ","];
pidlist = ReadList["ExampleData/pidAtomXYZpositions", Number, RecordSeparators -> ","];
pidAtomXYZpositions = Partition[pidlist, 3];
pidAtomTypes = ReadList["ExampleData/pidAtomTypes", Record, RecordSeparators -> ","];
tppAtomOccupation = Table[1.0, {ii, 1, Length[tppAtomTypes]}];
pidLength = Length[pidAtomXYZpositions];*)
(*pidTPPdata = Import[FileNameJoin[{$HomeDirectory, "Desktop", "Programming","mathematic","pidTPPdata.csv"}],"CSV"];*)
pidTPPdata = Import["packages/pidTPPdata.csv","CSV"];
pidTPPdata = Table[{pidTPPdata[[ii]][[1]], pidTPPdata[[ii]][[2]]}, {ii, 1, 
   Length[pidTPPdata]}];
   Print[pidTPPdata];
Get["PowderPackage.m" , Path->{"packages"}];
SetupPowder["/Users/HappyMandi/Desktop/Programming/ror/Powder/lib/mathematica/packages"];
(*sampled = SampleFourParamFunction[pidTPPdata, 0.44, -0.825, 11.49, 10.046, 0.000006313];*)
sampled2 = SampleFourParamFunction[pidTPPdata, param1, param2, param3, param4, 0.000006313];
(*sampled3 = SampleFourParamFunction[{{0.454, 539}}, param1, param2, param3, param4, 0.006313]*)
(*retval = fourParameterFunction[0.48,-0.825,11.49,10.046,0.000006313,0.45]*)
(*Print[Directory[]];*)
Export["sampled.json",sampled2]
