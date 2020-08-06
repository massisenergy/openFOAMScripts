#!/usr/bin/env bash
################################### REFERENCE ################################
#https://unix.stackexchange.com/a/588325/359467
#https://stackoverflow.com/a/61869488/9592557
################################# User_input #################################
#input directory names that need to be processed
STUDYNAME=AlgGel80kPa200DPsBluntedToGo63DPs
FOLDER=PF127_DP*/;#example of FOLDER value: <PF127*/>
#ouput filenames
swak4FoamAvgNu=swak4FoamAvgNu_$STUDYNAME;
MASTERSCRIPTSPATH=/home/msr/autoMount/Data_Documents/Dox_ownCloud/\
openFoamDataSR/Scripts_back-up
MODELDIRECTORYPATH=$MASTERSCRIPTSPATH/modelOFDirectoryBluntedBMD

##############################################################################
cd $STUDYNAME || break;

##############################################################################
# extract the maximum values of wallShearStress at the latest time

for DIR in $FOLDER; do
    # echo $DIR;
    cd $DIR &&
    # cp -v ../../model_OF_directory_conical_bMD/system/funkySetFieldsDict system/ &&
    cp -v $MODELDIRECTORYPATH/system/funkySetFieldsDict system/ &&
    funkySetFields -latestTime &&
    find . -type f -name '*avgNu*' -exec \
    awk -v DIR=$DIR '$0 ~ /internalField/ {gsub(/;/,"",$0); gsub(/\//,"",DIR);
    print DIR"\t\t"$3}' >> ../swak4FoamAvgNu.csv '{}' \;
    cd ..;
done;

printf "%s\n" $'0a\nMaterial_DP\tavgNu(m2s-1)' \
. x | ex -s $swak4FoamAvgNu.csv;
