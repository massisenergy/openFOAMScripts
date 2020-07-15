#!/usr/bin/env bash
# Takes input from Polyflow table of a conical nozzle design with five
# parameters in a .csv format, creates folders for each DP
# (design point) and reformats for legibility

# awk 'BEGIN {FS = ",";} {gsub(" ",""); print "mkdir "$1}' DOE_conical_2017Paxon_PF127_polyflow.csv | sh
# awk 'BEGIN{FS = ",";} (0 ~ "DP") {gsub(" ",""); system("mkdir "$1); system(cd $1); next;}' DOE_conical_2017Paxon_PF127_polyflow.csv > awk.csv
# awk 'BEGIN{FS = ",";} (0 ~ "DP") {gsub(" ",""); system("mkdir "$1); system("cd "$1); system("cat "$1" >> awk.csv")}' DOE_conical_2017Paxon_PF127_polyflow.csv

# awk 'BEGIN{FS = ",";} ($0 ~ "DP") {gsub(" ",""); system("mkdir "$1)}' DOE_conical_2017Paxon_PF127_polyflow.csv
# awk 'BEGIN {FS = ","; format1 = "%s \t %10.5e \t %10.5e \t %10.5e \t %10.5e \t %10.5e \n";
#     } {
#       if ($1 == "") {
#       print NR "\t" $0;
#     } else if (($2 ~ "Rbig") && ($3 ~ "Rsmall") && ($4 ~ "Rmiddle") && ($5 ~ "Lupper")) {
#       next
#     } else if ($1 ~ "DP"){
#       Rb = $2; Rs = $3; Rm = $4; Lu = $5; Ll = $6;
#       gsub(" ","");
#       printf(format1, $1, Rb, Rs, Rm, Lu, Ll);
#     }
# }' DOE_conical_2017Paxon_PF127_polyflow.csv > AWK.csv

awk 'BEGIN{FS = ",";
    format1 = "%s \t %10.5e \t %10.5e \t %10.5e \t %10.5e \t %10.5e \n";
    } {
      if ($1 == "")
        {print NR "\t" $0;}
      else if (($2 ~ "Rbig") && ($3 ~ "Rsmall") && ($4 ~ "Rmiddle") && ($5 ~ "Lupper"))
        {next;}
      else if ($1 ~ "DP")
        {Rb = $2; Rs = $3; Rm = $4; Lu = $5; Ll = $6;
        gsub(" ",""); system("mkdir "$1); filename=$1"/"$1".csv";
        printf(format1, $1, Rb, Rs, Rm, Lu, Ll) >> filename; close(filename);}
      }
' DOE_conical_2017Paxon_PF127_polyflow.csv #> AWK.csv
