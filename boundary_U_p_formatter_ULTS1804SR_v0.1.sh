#!/usr/bin/env bash
################################## Description #################################
# this awk script takes two `U` file needed for openFOAM, found in `0`
# directory of every project and formats a new U file, with input from
# a suitable `constant/polyMesh/boundary` file for assignement of
# patches (boundaary conditions)
################################################################################

mv constant/polyMesh/boundary constant/polyMesh/boundary_backup;
awk 'NR<=17 {print;}
    NR==18 {print "5";}
    NR==19 {print;}
    NR>19 && NR<41 {next;}
    $0~"auto0" {gsub("auto0","auto0//wedgeBack"); print;}
    NR==43 && $0~"type" {gsub("patch;","wedge;//wedgeBack"); print;}
    $0~"auto1" {gsub("auto1","auto1//wedgeFront"); print;}
    NR==49 && $0~"type" {gsub("patch;","wedge;//wedgeFront"); print;}
    $0~"auto2" {gsub("auto2","auto2//wall"); print;}
    NR==55 && $0~"type" {gsub("patch;","wall;//wall"); print;}
    $0~"auto3" {gsub("auto3","auto3//outlet"); print;}
    NR==61 && $0~"type" {gsub("patch;","patch;//outlet"); print;}
    $0~"auto4" {gsub("auto4","auto4//inlet"); print;}
    NR==67 && $0~"type" {gsub("patch;","patch;//inlet"); print;}
    $0~"type" && NR>=21 {next;}
    $0!~"auto" && NR>=21 {print;}
' constant/polyMesh/boundary_backup > constant/polyMesh/boundary;
################################################################################

################################################################################
# next two AWK scripts formats `U` & `p` respectively, using `boundary`.
#this is for fromatting the U file
awk 'BEGIN{
    print \
    "/*--------------------------------*- C++ -*----------------------------------*\\"\
    "\n  =========                 |"\
    "\n  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox"\
    "\n   \\    /   O peration     | Website:  https://openfoam.org"\
    "\n    \\  /    A nd           | Version:  7"\
    "\n     \\/     M anipulation  |"\
    "\n\\*---------------------------------------------------------------------------*/"\
    "\nFoamFile"\
    "\n{"\
    "\n    version     2.0;"\
    "\n    format      ascii;"\
    "\n    class       volVectorField;"\
    "\n    object      U;"\
    "\n}"\
    "\n// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"\
    "\n"\
    "\ndimensions      [0 1 -1 0 0 0 0];"\
    "\n"\
    "\ninternalField   uniform (0 0 0);"\
    "\n"\
    "\nboundaryField"\
    "\n{"
}' > 0/U

awk 'BEGIN{FS=" "; vely = "-1E-2"}{
    if (NR <=19) {
        next;
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "inlet")) {
        print "\t"$1"\t\t""fixedValue;";
        print "\t""value""\t\t""uniform (0 "vely" 0);"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "outlet")) {
        print "\t"$1"\t\t""zeroGradient;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wall;")) {
        print "\t"$1"\t\t""noSlip;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wedge")) {
        gsub("empty;","wedge;"); print;
    } else if ((NF == 2) && ($1 == "physicalType" || "nFaces" || "startFace")) {
        next;
    } else if ((NF == 1) && ($0 == ")")) {
        print "}";
    } else {
        print;
    }
}' constant/polyMesh/boundary >> 0/U
################################################################################

################################################################################
#this is for fromatting the p file
awk 'BEGIN{
    print \
    "/*--------------------------------*- C++ -*----------------------------------*\\"\
    "\n  =========                 |"\
    "\n  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox"\
    "\n   \\    /   O peration     | Website:  https://openfoam.org"\
    "\n    \\  /    A nd           | Version:  7"\
    "\n     \\/     M anipulation  |"\
    "\n\\*---------------------------------------------------------------------------*/"\
    "\nFoamFile"\
    "\n{"\
    "\n    version     2.0;"\
    "\n    format      ascii;"\
    "\n    class       volScalarField;"\
    "\n    object      p;"\
    "\n}"\
    "\n// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"\
    "\n"\
    "\ndimensions      [0 2 -2 0 0 0 0];"\
    "\n"\
    "\ninternalField   uniform 0;"\
    "\n"\
    "\nboundaryField"\
    "\n{"
}' > 0/p

awk 'BEGIN{FS=" "; vely = "-1E-4"}{
    if (NR <=19) {
        next;
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "outlet")) {
        print "\t"$1"\t\t""fixedValue;";
        print "\t""value""\t\t""uniform 0;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "inlet")) {
        print "\t"$1"\t\t""zeroGradient;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wall;")) {
        print "\t"$1"\t\t""zeroGradient;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wedge")) {
        gsub("empty;","wedge;"); print;
    } else if ((NF == 2) && ($1 == "physicalType" || "nFaces" || "startFace")) {
        next;
    } else if ((NF == 1) && ($0 == ")")) {
        print "}";
    } else {
        print;
    }
}' constant/polyMesh/boundary >> 0/p
############################################################################

################################################################################
# old stuffs
# this is for fromatting the boundary patches
# awk '{
#     	if ((NF == 2) && ($1 == "type")) {
#         	print "\t\t"$1"\t\t\t""wall;"
#     	} else if ((NF == 2) && ($1 == "physicalType")) {
#
#     	} else {
#         	print
#     	}
# }' boundary > boundary_updated
# ##########################################

################################################################################

# awk '{
#     if ((NR <=19) || (NR>= 50)) {
#
#     } else if ((NF == 2) && ($1 == "type") && ($2 == "wall;")) {
#         print "\t\t"$1"\t\t\t""noSlip;"
#     } else if ((NF == 2) && ($1 == "physicalType" || "nFaces" || "startFace")) {
#
#     } else if ((NF == 1) && ($0 == ")")) {
#         print "}"
#     } else if ($0 ~ "//outlet") {FS == "\n" && RS == "}";
#         print
#         # print "\t\t"$1"\n\t\t{"
#     } else {
#         print
#     }
# }' boundary
# ################################################################################
