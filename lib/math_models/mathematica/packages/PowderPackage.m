(* ::Package:: *)

BeginPackage["PowderPackage`"]

GetPath::usage = "get the set path";
SetupPowder::usage = "provide the path to the folder containing the setup files";

hexagonalABCtppPositiveFolded::usage = "function gives the (a, b, c) position lists";
hexagonalABCtppPositiveFoldedComp::usage = "function version also produces the (a, b, c) coordinates, but is a compiled function that may be useful for faster execution of the code";
hexagonaltppPositiveFolded::usage = "version takes the (a, b, c) coordinates, and uses the inverse matrix to return to the (x, y, z) coordinates";
hexagonalABCPIDPositiveFolded::usage = "first benzene molecule";
hexagonalABCPIDPositiveFoldedComp::usage = "first benzene molecule, compiled";
hexagonalPIDPositiveFolded::usage = "No description yet";
hexagonalABCPID2PositiveFolded::usage = "No description yet";
hexagonalABCPID2PositiveFoldedComp::usage = "No description yet";

hexagonalPID2PositiveFolded::usage = "version takes the (a, b, c) coordinates, and uses the inverse matrix to return to the (x, y, z) coordinates"; 
hexagonalABCPIDNegativeFolded::usage = "PID085 molecule, but this time inverted.  The idea is that the TPP unit cell is typically inversion symmetric, so any included molecule could
also be included in an inverted situation.  In the typical crystal, both the regular and inverted configurations are likely found.";

hexagonalABCPIDNegativeFoldedComp::usage = "PID085 molecule, but this time inverted.  The idea is that the TPP unit cell is typically inversion symmetric, so any included molecule could
also be included in an inverted situation.  In the typical crystal, both the regular and inverted configurations are likely found.";

hexagonalPIDNegativeFolded::usage = "No description yet";

hexagonalABCPID2NegativeFolded::usage = "No description yet";
hexagonalABCPID2NegativeFoldedComp::usage = "No description yet";

hexagonalPID2NegativeFolded::usage = "No description yet";
hexagonalABCtppNegativeFolded::usage = "No description yet";
hexagonalABCtppNegativeFoldedComp::usage = "No description yet";
hexagonaltppNegativeFolded::usage = "No description yet";

atomicFormFactorComp::usage = "No description yet";

qValueHKL::usage = "No description yet";
qValueHKLcomp::usage = "No description yet";

structureFactorInvSymmHalfComp::usage = "No description yet";
intAreaTableInvSymm::usage = "No description yet";

powderXRDfunctionInvSymm::usage = "TBA";
fourParameterFunction::usage = "TBA";
SampleFourParamFunction::usage = "TBA";

GetBraggList::usage = "Get the braggMultiplicityListSimple values";

Chi2Test::usage = "TBA";
SingleChiSquare::usage = "TBA";

Begin["`Private`"]

path = "";

tppAtomXYZpositions;
tppAtomTypes;
tppAtomOccupation;

pidAtomXYZpositions;
pidAtomTypes;
pidAtomOccupation;
pidLength;

pid2AtomXYZpositions;
pid2AtomTypes;
pid2AtomOccupation;
pid2Length;

fullPIDintppUnitCellVertexTypes;
fullPIDintppUnitCellAtomicNumbers;

halfPIDintppUnitCellVertexTypes;
halfPIDintppUnitCellAtomicNumbers;

formFactorInfo;
formFactorPTable;

braggMultiplicityListSimple;

pidTPPdata;
pidTPPPointList;

intAreaList;

transMatrix ={{1/Sqrt[3],1,0},{-1/Sqrt[3],1,0},{0,0,1}};
inverseTransMatrix = Inverse[transMatrix];


SetupPowder[path0_]:= Module[{},
	path = path0;
	tppAtomXYZpositions = Import[FileNameJoin[{path, "tppAtomXYZpositions.json"}], "JSON"];
	tppAtomTypes = Import[FileNameJoin[{path,"tppAtomTypes.json"}],"JSON"];
	tppAtomOccupation =Import[FileNameJoin[{path, "tppAtomOccupation.json"}], "JSON"];
	pidAtomXYZpositions = Import[FileNameJoin[{path, "pidAtomXYZpositions.json"}], "JSON"];
	pidAtomTypes = Import[FileNameJoin[{path, "pidAtomTypes.json"}], "JSON"];
	pidAtomOccupation = Import[FileNameJoin[{path, "pidAtomOccupation.json"}], "JSON"];
	pidLength = Length[pidAtomXYZpositions];
	pid2AtomXYZpositions = pidAtomXYZpositions;
	pid2AtomTypes = pidAtomTypes;
	pid2AtomOccupation = pidAtomOccupation;
	pid2Length = pidLength;

	fullPIDintppUnitCellVertexTypes = Join[tppAtomTypes,pidAtomTypes,pidAtomTypes,pid2AtomTypes,pid2AtomTypes,tppAtomTypes];

	fullPIDintppUnitCellAtomicNumbers = Table[ 
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="H",1,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="He",2,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="Li",3,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="Be",4,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="B",5,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="C",6,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="N",7,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="O",8,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="P",15,
		If[fullPIDintppUnitCellVertexTypes[[ii]]=="SI",14]]]]]]]]]],
		{ii,1,Length[fullPIDintppUnitCellVertexTypes]}
	];

	formFactorInfo = Import[FileNameJoin[{path,"formFactorInfo.csv"}],"CSV"];
	formFactorPTable = Table[{formFactorInfo[[ii]][[2]],
		formFactorInfo[[ii]][[3]],
		formFactorInfo[[ii]][[4]],
		formFactorInfo[[ii]][[5]],
		formFactorInfo[[ii]][[6]],
		formFactorInfo[[ii]][[7]],
		formFactorInfo[[ii]][[8]],
		formFactorInfo[[ii]][[9]],
		formFactorInfo[[ii]][[10]]},{ii,1,Length[formFactorInfo]}
	];

	(* braggMultiplicityListSimple = Import["braggMultiplicityListSimple","List"]; *)

braggMultiplicityListSimple  ={{6,{{-1,0,0}}},{2,{{0,0,-1}}},{12,{{-1,0,-1}}},{6,{{-2,1,0}}},{6,{{-2,0,0}}},{12,{{-2,1,-1}}},{2,{{0,0,-2}}},{12,{{-2,0,-1}}},{12,{{-1,0,-2}}},{12,{{-3,1,0},{1,-3,0}}},{12,{{-2,1,-2}}},{24,{{-3,1,-1},{1,-3,-1}}},{12,{{-2,0,-2}}},{6,{{-3,0,0}}},{12,{{-3,0,-1}}},{2,{{0,0,-3}}},{12,{{-1,0,-3}}},{24,{{-3,1,-2},{1,-3,-2}}},{6,{{-4,2,0}}},{12,{{-4,1,0},{1,-4,0}}},{12,{{-4,2,-1}}},{12,{{-2,1,-3}}},{12,{{-3,0,-2}}},{24,{{-4,1,-1},{1,-4,-1}}},{12,{{-2,0,-3}}},{6,{{-4,0,0}}},{12,{{-4,2,-2}}},{12,{{-4,0,-1}}},{24,{{-3,1,-3},{1,-3,-3}}},{24,{{-4,1,-2},{1,-4,-2}}},{2,{{0,0,-4}}},{4,{{-3,-2,0},{-2,-3,0}}}};

	pidTPPdata = Import[FileNameJoin[{path,"pidTPPdata.csv"}],"CSV"];
	pidTPPPointList = Table[{pidTPPdata[[ii]][[1]],pidTPPdata[[ii]][[2]]},{ii,1,Length[pidTPPdata]}];

	halfPIDintppUnitCellVertexTypes=Join[tppAtomTypes,pidAtomTypes,pidAtomTypes];

	halfPIDintppUnitCellAtomicNumbers = Table[ 
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="H",1,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="He",2,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="Li",3,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="Be",4,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="B",5,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="C",6,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="N",7,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="O",8,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="P",15,
		If[halfPIDintppUnitCellVertexTypes[[ii]]=="SI",14]]]]]]]]]],
		{ii,1,Length[halfPIDintppUnitCellVertexTypes]}
	];
];


GetPath[] := Return[path];

hexagonalABCtppPositiveFolded[gamma_,amag_,cmag_] := Table[
	Module[
		{coord},
		coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.tppAtomXYZpositions[[i]] + {amag/(2*Sqrt[3]),amag/2,cmag/4});
		If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
		If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
		If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
		coord
	] ,
	{i,1,42}
];

hexagonalABCtppPositiveFoldedComp = Compile[
	{{gamma,_Real},{amag,_Real},{cmag,_Real}}, 
	Table[
		Module[
			{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.tppAtomXYZpositions[[i]] + {amag/(2*Sqrt[3]),amag/2,cmag/4});
			If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
			If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
			If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
			coord
		] ,
	{i,1,42}]
];

hexagonaltppPositiveFolded[gamma_,amag_,cmag_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.tppAtomXYZpositions[[i]] + {amag/(2*Sqrt[3]),amag/2,cmag/4});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord=inverseTransMatrix.coord;
coord
] ,{i,1,42}];


hexagonalABCPIDPositiveFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.pidAtomXYZpositions[[i]] + {0.,0.,(cmag/2.)+zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pidLength}];

hexagonalABCPIDPositiveFoldedComp =Compile[{{gamma,_Real},{amag,_Real},{cmag,_Real}, {zoff,_Real}}, Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.pidAtomXYZpositions[[i]] + {0.,0.,(cmag/2.)+zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pidLength}]
];

hexagonalPIDPositiveFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.pidAtomXYZpositions[[i]] + {0.,0.,(cmag/2.)+zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord=inverseTransMatrix.coord;
coord
] ,{i,1,pidLength}];

hexagonalABCPID2PositiveFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.pid2AtomXYZpositions[[i]] + {0.,0.,(cmag/2.)+zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pid2Length}]

hexagonalABCPID2PositiveFoldedComp =Compile[{{gamma,_Real},{amag,_Real},{cmag,_Real}, {zoff,_Real}}, Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.pid2AtomXYZpositions[[i]] + {0.,0.,(cmag/2.)+zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pid2Length}]
];

hexagonalPID2PositiveFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.pid2AtomXYZpositions[[i]] + {0.,0.,(cmag/2.)+zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord=inverseTransMatrix.coord;
coord
] ,{i,1,pid2Length}];

hexagonalABCPIDNegativeFoldedComp =Compile[{{gamma,_Real},{amag,_Real},{cmag,_Real},{zoff,_Real}}, Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pidAtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pidLength}]
];

hexagonalABCPIDNegativeFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pidAtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pidLength}]

hexagonalABCPIDNegativeFoldedComp =Compile[{{gamma,_Real},{amag,_Real},{cmag,_Real},{zoff,_Real}}, Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pidAtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pidLength}]
];

hexagonalPIDNegativeFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pidAtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord=inverseTransMatrix.coord;
coord
] ,{i,1,pidLength}];

hexagonalABCPID2NegativeFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pid2AtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pid2Length}];

hexagonalABCPID2NegativeFoldedComp =Compile[{{gamma,_Real},{amag,_Real},{cmag,_Real},{zoff,_Real}}, Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pid2AtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,pid2Length}]
];

hexagonalPID2NegativeFolded[gamma_,amag_,cmag_,zoff_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-pid2AtomXYZpositions[[i]]) + {0.,0.,(cmag/2.)-zoff});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord=inverseTransMatrix.coord;
coord
] ,{i,1,pid2Length}];

hexagonalABCtppNegativeFolded[gamma_,amag_,cmag_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-tppAtomXYZpositions[[i]]) + {-amag/(2*Sqrt[3]),amag/2,cmag*3/4});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,42}];

hexagonalABCtppNegativeFoldedComp = Compile[{{gamma,_Real},{amag,_Real},{cmag,_Real}}, Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-tppAtomXYZpositions[[i]]) + {-amag/(2*Sqrt[3]),amag/2,cmag*3/4});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord
] ,{i,1,42}]
];

hexagonaltppNegativeFolded[gamma_,amag_,cmag_] := Table[Module[{coord},coord = transMatrix.({{Cos[gamma], -Sin[gamma], 0},{Sin[gamma],Cos[gamma],0},{0,0,1}}.(-tppAtomXYZpositions[[i]]) + {-amag/(2*Sqrt[3]),amag/2,cmag*3/4});
If[coord[[1]]<0.0,coord[[1]]=coord[[1]]+amag,If[coord[[1]]>amag,coord[[1]]=coord[[1]]-amag]];
If[coord[[2]]<0.0,coord[[2]]=coord[[2]]+amag,If[coord[[2]]>amag,coord[[2]]=coord[[2]]-amag]];
If[coord[[3]]<0.0,coord[[3]]=coord[[3]]+cmag,If[coord[[3]]>cmag,coord[[3]]=coord[[3]]-cmag]];
coord=inverseTransMatrix.coord;
coord
] ,{i,1,42}];

atomicFormFactorComp = Compile[{{atom, _Integer}, {scatterQ, _Real}},
   Module[{lineNumber, value = 0.0},
    lineNumber = atom;
    value = formFactorPTable[[lineNumber]][[9]] + \!\(
\*UnderoverscriptBox[\(\[Sum]\), \(ii = 1\), \(4\)]\((\(formFactorPTable[\([lineNumber]\)]\)[\([2\ ii\  - 1]\)]\ 
\*SuperscriptBox[\(E\), \(-\((\(formFactorPTable[\([lineNumber]\)]\)[\([2\ ii\ ]\)]\ 
\*SuperscriptBox[\((
\*FractionBox[\(scatterQ\), \(4\ \[Pi]\)])\), \(2\)])\)\)])\)\);
    value
    ]
   ];

qValueHKL[aHex_, cHex_, h_, k_, l_] := 
 2 Pi Sqrt[4/(3 aHex^2) (h^2 + h k + k^2) + l^2/cHex^2];

qValueHKLcomp = 
  Compile[ {{aHex, _Real}, {cHex, _Real}, {h, _Integer}, {k, \
_Integer}, {l, _Integer}},
   	Module[ {root}, 
    root = 2 Pi Sqrt[4/(3 aHex^2) (h^2 + h k + k^2) + l^2/cHex^2]; 
    root]];

structureFactorInvSymmHalfComp =Compile[{{gamma1,_Real},{gamPID1,_Real},{occ1,_Real},{zoff1,_Real},{gamPID2,_Real},{occ2,_Real},{zoff2,_Real},{aHex,_Real},{cHex,_Real},{h,_Integer},{k,_Integer},{l,_Integer}},Module[{qhkl=0.0,numAtoms=0.0,atomPositionListPos={{0.,0.,0.}},atomPositionListPIDPos={{0.,0.,0.}},atomPositionListPID2Pos={{0.,0.,0.}},atomPositionListPIDNeg={{0.,0.,0.}},atomPositionListNeg={{0.,0.,0.}},atomPosList={{0.,0.,0.}},pidAtomOcc={0.},pid2AtomOcc={0.},atomOccList={0.},sfactor=0.},
qhkl = qValueHKLcomp[aHex,cHex,h,k,l];
pidAtomOcc = Table[occ1, {ii,1,Length[pidAtomTypes]}];
pid2AtomOcc = Table[occ2, {ii,1,Length[pid2AtomTypes]}];
atomOccList= Join[tppAtomOccupation,pidAtomOcc,pid2AtomOcc];(*,pid061AtomOccupation,tppAtomOccupation];*)
numAtoms = Length[atomOccList];
atomPositionListPos = hexagonalABCtppPositiveFoldedComp[gamma1,aHex,cHex];
(*atomPositionListNeg = hexagonalABCtppNegativeFoldedComp[gamma1,aHex,cHex];*)
atomPositionListPIDPos = hexagonalABCPIDPositiveFoldedComp[gamPID1,aHex,cHex,zoff1];
atomPositionListPID2Pos = hexagonalABCPID2PositiveFoldedComp[gamPID2,aHex,cHex,zoff2];
(*atomPositionListPIDNeg = hexagonalABCPID061NegativeFoldedComp[gamma2,aHex,cHex];*)
atomPosList = Join[atomPositionListPos ,atomPositionListPIDPos ,atomPositionListPID2Pos ];(*,atomPositionListPID061Neg , atomPositionListNeg];*)
sfactor =2*\!\(
\*UnderoverscriptBox[\(\[Sum]\), \(ii = 1\), \(numAtoms\)]\((atomOccList[\([ii]\)]\ *\ atomicFormFactorComp[halfPIDintppUnitCellAtomicNumbers[\([ii]\)], qhkl]\ \[IndentingNewLine]*Cos[2\ \[Pi]\ \((h*\(atomPosList[\([ii]\)]\)[\([1]\)]/aHex\  + \ \[IndentingNewLine]k*\(atomPosList[\([ii]\)]\)[\([2]\)]/aHex\  + \ \[IndentingNewLine]l*\(atomPosList[\([ii]\)]\)[\([3]\)]/cHex)\)])\)\);
sfactor
]
];

intAreaTableInvSymm[gamma1_, gamPID1_, occ_, zoff1_, gamPID2_, frac1_,
   zoff2_, aHex_, cHex_, bragglist_] := Table[
  {qValueHKL[aHex, cHex, bragglist[[ii]][[2]][[1]][[1]], 
    bragglist[[ii]][[2]][[1]][[2]], bragglist[[ii]][[2]][[1]][[3]]], 
   Module[{sfactor, intArea, lenList},
    lenList = Length[bragglist[[ii]][[2]]];
    intArea = (1.0*bragglist[[ii]][[1]]/lenList)*(\!\(
\*UnderoverscriptBox[\(\[Sum]\), \(jj = 1\), \(lenList\)]
\*SuperscriptBox[\((structureFactorInvSymmHalfComp[gamma1, gamPID1, \((occ*frac1/6.0)\), zoff1*100.0, gamPID2, \((occ*\((1 - frac1)\)/6.0)\), zoff2*100.0, aHex*100.0, cHex*100.0, \(\(\(bragglist[\([ii]\)]\)[\([2]\)]\)[\([jj]\)]\)[\([1]\)], \(\(\(bragglist[\([ii]\)]\)[\([2]\)]\)[\([jj]\)]\)[\([2]\)], \(\(\(bragglist[\([ii]\)]\)[\([2]\)]\)[\([jj]\)]\)[\([3]\)]])\), \(2\)]\) );
    intArea]},
  {ii, 1, Length[bragglist]}
  ];

powderXRDfunctionInvSymm[gamma1_?NumericQ,gamPID1_?NumericQ,occ_?NumericQ,zoff1_?NumericQ,gamPID2_?NumericQ,frac1_?NumericQ,zoff2_?NumericQ,aHex_?NumericQ,cHex_?NumericQ, dia_?NumericQ,strain_?NumericQ,scale_?NumericQ,wid0_?NumericQ,peakType_?NumericQ,bragglist_,tempFactor_?NumericQ,bh1_?NumericQ,bh2_?NumericQ,bh3_?NumericQ,bh4_?NumericQ,bh5_?NumericQ,bh6_?NumericQ,bh7_?NumericQ,bh8_?NumericQ,bconst_?NumericQ,monoScale_?NumericQ,monoDev_?NumericQ,qVal_?NumericQ]:=Module[{lambda,theta,lorentzFactor,lenList,multi=1.0,sfactor,intArea, qCenter,widQ,totInt=0.0,backg = 0.0},
lambda=1.5418;
theta=ArcSin[lambda*qVal/(4*\[Pi])];
lorentzFactor=(1+(Cos[2*theta])^2)/(((Sin[theta])^2)*Cos[theta]);
widQ=wid0+(0.9*lambda/(dia*Cos[theta])) + strain*Tan[theta];
lenList = Length[bragglist];
(*troubleList=Append[troubleList,qVal];*)
(*intAreaList = intAreaTableInvSymm[gamma1, gamma2,occ,aHex,cHex, bragglist];*)
If[qVal<=0.450,intAreaList = intAreaTableInvSymm[gamma1, gamPID1,occ,zoff1, gamPID2,frac1,zoff2,aHex,cHex, bragglist]];
For[ii=1,ii<=lenList,ii++,
	qCenter = intAreaList[[ii]][[1]];

	(*multi = bragglist[[ii]][[1]];*)
	intArea = intAreaList[[ii]][[2]];
	totInt = totInt + intArea*((1-peakType)*(1/(widQ Sqrt[2\[Pi]]))*Exp[-0.5*((qVal-qCenter)/widQ)^2]+(peakType*(1/(widQ \[Pi]))/(((qVal-qCenter)/widQ)^2+1)));
	(*Print["intArea"<>intArea<>"peakType"<>peakType<>"widQ"<>widQ<>"qVal"<>qVal<>"qCenter"<>qCenter"totInt"<>totInt];*)
];
backg=bh1*Exp[-0.5*((qVal-0.403)/0.0222)^2] + 
bh2*Exp[-0.5*((qVal-0.5)/0.2)^2] +
bh3*Exp[-0.5*((qVal-0.8)/0.2)^2] +
bh4*Exp[-0.5*((qVal-1.1)/0.2)^2] +
bh5*Exp[-0.5*((qVal-1.4)/0.2)^2] +
bh6*Exp[-0.5*((qVal-1.7)/0.2)^2] +
bh7*Exp[-0.5*((qVal-2.0)/0.2)^2] +
bh8*Exp[-0.5*((qVal-2.3)/0.2)^2];
totInt = (totInt*scale*Exp[-2*tempFactor*qVal^2] +backg)*lorentzFactor +
bconst+
monoScale*monoFun[qVal]*Exp[-2*monoDev*qVal^2];
totInt
];

fourParameterFunction[(gamma1_)?NumericQ, (gamPID1_)?NumericQ, (aHex_)?NumericQ, (cHex_)?NumericQ, (scale_)?NumericQ, 
   (qVal_)?NumericQ] := powderXRDfunctionInvSymm[gamma1, gamPID1, 1., 2.5, 1., 1., -2.5, aHex, cHex, 3000., 0., scale, 0.003, 
   0.5, braggMultiplicityListSimple, 0.09, 1.6, 0.388, 0.277, 0.569, 2.01, 3., 1.75, 0.6, 120., 0., 0.1, qVal];

SampleFourParamFunction[measuredData_, (gamma1_)?NumericQ, (gamPID1_)?NumericQ, (aHex_)?NumericQ, (cHex_)?NumericQ, (scale_)?NumericQ] := Module[
{m=measuredData, n, retval={},funcval, gamma=gamma1,gampid=gamPID1, ahex=aHex,chex=cHex,s=scale},
n=Length[m];
For[i=1, i<=n, i++,
funcval=fourParameterFunction[gamma,gampid,ahex,chex,s,m[[i]][[1]]];
AppendTo[m[[i]],funcval];
AppendTo[retval,m[[i]]];
];
Return[retval]
]

GetBraggList[]:= Return[braggMultiplicityListSimple];

SingleChiSquare[o0_, e0_] := Module[
   {o = o0, e = e0},
   Return[((o - e)^2)/e]
];

Chi2Test[list0_] := Module[{list = list0, n, sum = 0},
   n = Length[list];
   For[i = 1, i <= n, i++,
    sum += SingleChiSquare[list[[i]][[3]], list[[i]][[2]]]
    ];
   Return[sum/n];
];

End[]
EndPackage[]



