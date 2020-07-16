#!/usr/bin/env bash
################################### REFERENCE ################################
#https://unix.stackexchange.com/a/588325/359467
#https://stackoverflow.com/a/61869488/9592557
################################# User_input #################################
#input directory names that need to be processed
STUDYNAME=Alg340kPaConicalFlowRate
#example of FOLDER value: <PF127*/>
FOLDER=Alg_DP*/
#ouput filenames
WSSMATCH=lowerNozzleWall;#name of the patch to calculate WSS
PPWSS=pPWSS_$WSSMATCH_$STUDYNAME;
PPFLUXOUTLET=pPfluxOutlet_$STUDYNAME;
PPAVGNUU=pPAvgNuU_$STUDYNAME;
FLUXMATCH=NONE;

cd $STUDYNAME || exit;
##############################################################################

# extract the maximum values of wallShearStress at the latest time
while IFS= read -r files; do
    # echo $files;
    awk -v WSSMATCH="$WSSMATCH" 'NR==FNR && $0 ~ WSSMATCH {LastLine=FNR; next;}
    FNR==LastLine {gsub(/\(/,"",$0); gsub(/(\/.+)/,"",FILENAME);
    magWSS=(($7**2+$8**2)**0.5)
    print FILENAME"\t"$1"\t"$2"\t"magWSS}' "$files" "$files" \
    >> $PPWSS.csv;
done < <(\
         for d in $FOLDER; do find "$d" -type f -name 'wallShearStress.dat' ;
             # -not -name 'wallShearStress.dat' | \
             # sort -Vk2 -t.| tail -n 1;
         done;)

printf \
"%s\n" $'0a\nMaterial_DP\tsimulationTime\tpatch\tmagnitudeWSS(Pa)' \
. x | ex -s $PPWSS.csv;

##############################################################################
# extract the Average values of nu & U from the postProcessing directory at
# all simulationTime
while IFS= read -r DIR; do
    # echo $dir;
    if [[ $DIR =~ flowRatePatch\(name=outlet\) ]]; then
      # echo $'T\n'$dir;
      awk 'NR==FNR{LastLine=FNR; next;}
      FNR==LastLine {gsub(/\(/,"",$0); gsub(/(\/.+)/,"",FILENAME);
      flowRateOut=($2*72*1e9);
      print FILENAME"\t\t"$1"\t"$2"\t"flowRateOut}' "$DIR" "$DIR"\
      >> $PPFLUXOUTLET.csv;
    # elif [[ $DIR =~ flowRatePatch\(name=inlet\) ]]; then
    #   awk '
    #   $1 ~ /[0-9]/ && $0 != 0 {gsub(/\(/,"",$0); gsub(/(\/.+)/,"",FILENAME);
    #   flowRateIn=($2*72*1e9);
    #   print FILENAME"\t\t"$1"\t"$2"\t"flowRateIn}' "$DIR"
    #   #>> $pPfluxInlet_DP208.csv;
    elif
    [[ $DIR =~ \(name=outlet,U,nu\) ]]; then
      awk 'NR==FNR{LastLine=FNR; next;}
      FNR==LastLine {gsub(/\(|\)/,"",$0); gsub(/(\/.+)/,"",FILENAME);
      magU=(($2**2+$3**2)**0.5);
      print FILENAME"\t\t"$1"\t"$2"\t"$3"\t"$5"\t"magU}' "$DIR" "$DIR"\
      >> $PPAVGNUU.csv;
    fi;
done < <(\
         for d in $FOLDER; do find "$d" -type f -name 'surfaceFieldValue.dat' \
             # -not -name 'surfaceFieldValue.dat' | \
             # sort -Vk2 -t.| tail -n 1;
         done;) || exit;

printf "%s\n" 0a \
$'Material_DP\tRs\tsimulationTime\tflux(ms-1)\tflowRate(µLs-1)' \
. x | ex -s $PPFLUXOUTLET.csv;
printf "%s\n" 0a \
$'Material_DP\tRs\tsimulationTime\tavgUx(ms-1)\tavgUy(ms-1)\tavgNu(m2s-1)\tmagAvgU(ms-1)' \
. x | ex -s $PPAVGNUU.csv;

##############################################################################

# NR == 1 {print "DP\t\tsimulationTime\t\tphi"}
# NR==1{print "DP\t\tsimulationTime\tavgUx\tavgUy\tavgNu"}
# /patchAverage(name=outlet,U,nu)/0/

# for d in $FOLDER; do find "$d" -type d \
#     -wholename 'postProcessing/patchAverage(name=outlet,U,nu)/0';
#         for j in find '{}' -type f -name 'surfaceFieldValue.dat' \;;
#     # sort -Vk2 -t.| tail -n 1;
# done;
