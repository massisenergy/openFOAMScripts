#!/bin/bash
# extract the maximum values of f at the latest time postProcessing

################################# User_input ###################################
#input directory names that need to be processed
folder=PF127*/;#example: <PF127*/>

################################################################################

while IFS= read -r files; do
    # echo $files;
    awk 'NR==3{gsub(/\(/,"",$0); gsub(/(\/.+)/,"",FILENAME);
    print FILENAME"\t\t"$1"\t"$6"\t"$7}' $files >> postProcessing_WSS.csv;
done < <(\
         for d in $folder; do find "$d" -type f -name 'wallShearStress*.dat' \
             -not -name 'wallShearStress.dat' | \
             sort -Vk2 -t.| tail -n 1;
         done;)

#this gets stuck after one iteration
# for d in DP*/; do
#     find "$d" -type f -name 'wallShearStress*' | \
#     sort -Vk2 -t. | head -n1;
#     while IFS= read -r files; do
#         # echo Do something with "$files"
#         tail -n +3 | awk 'NR == 3 {print $0}' $files;
#     done;
# done;

