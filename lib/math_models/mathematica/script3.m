#!/Applications/Mathematica.app/Contents/MacOS/MathematicaScript -script

param1 = ToExpression[$ScriptCommandLine[[2]]];
param2 = ToExpression[$ScriptCommandLine[[3]]];
param3 = ToExpression[$ScriptCommandLine[[4]]];
param4 = ToExpression[$ScriptCommandLine[[5]]];
list = ReadList["ExampleData/tppAtomXYZpositions", Number, RecordSeparators -> ","];

pidTPPdata = Import["packages/pidTPPdata.csv","CSV"];
pidTPPdata = Table[{pidTPPdata[[ii]][[1]], pidTPPdata[[ii]][[2]]}, {ii, 1, Length[pidTPPdata]}];
Get["PowderPackage.m" , Path->{"packages"}];
SetupPowder["/Users/HappyMandi/Desktop/Programming/ror/Powder/lib/mathematica/packages"];

sampled = SampleFourParamFunction[pidTPPdata, param1, param2, param3, param4, 0.000006313];
chi2 = Chi2Test[sampled];
string = ExportString[{"sampled"->sampled, "chi2"->chi2},"JSON"];
Export["sampled.json",string]
