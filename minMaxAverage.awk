#!/bin/bash
# Usage: awk -f-F "fs" <thisFIle> <file_to_process>, for example:
# awk -F "," 'BEGIN{cnt=0} $0 !~/[a-ZA-Z]/ {s1+=$1; s2+=$2; s3+=$3; cnt++}END{
# 	print "Avg = "s1/cnt, s2/cnt, s3/cnt}' U_Magnitude_nu_Outlet.csv
################################################################################

BEGIN {cnt=0; format="%.2g\t%.2g\t%.2f\t%.2f\t%.2f\n";}
 NR==1 && $0 ~/[a-ZA-Z]/ {
	var1=$1; var2=$2; var3=$3; var4= $4; cnt++;
	maxs1 = 0; maxs2 = 0; maxs3 = 0; maxs4 = 0; maxs5 = 0; maxs6 = 0;}
	# mins1 = 0; mins2 = 0; mins3 = 0; mins4 = 0; mins5 = 0; mins6 = 0;}
$0 !~/[a-zA-Z]/ {
	s1+=$1; s2+=$2; s3+=$3; cnt++;{
		if (maxs1<$1) maxs1 = $1; if (maxs2<$2) maxs2 = $2; if (maxs3<$3)
		maxs3 = $3;	if (maxs4<$4) maxs4 = $4; if (maxs5<$5) maxs5 = $5;
		}{
		mins1=$1<mins1||mins1==""?$1:mins1; mins2=$2<mins2||mins2==""?$2:mins2;
		mins3=$3<mins3||mins3==""?$3:mins3; mins4=$4<mins4||mins4==""?$4:mins4;
		mins5=$5<mins5||mins5==""?$5:mins5; mins6=$6<mins6||mins6==""?$6:mins6;
		}
	} END {
	print "Variables = "var1, var2, var3;
	print "Min = "mins1, mins2, mins3, mins4, mins5, mins6;
	print "Max = "maxs1, maxs2, maxs3, maxs4, maxs5, maxs6;
	print "Avg = " s1/cnt, s2/cnt, s3/cnt, s4/cnt, s5/cnt, s6/cnt;
	printf(format, s1/cnt, s2/cnt, s3/cnt, s4/cnt, s5/cnt, s6/cnt);
}

##################################### OLD ######################################
# $0 ~ /[a-zA-Z]/ && NR == 1 {
# 	$0 = header; cnt = 0}
#
# NR > 1 && $2 ~ /[0-9]/{
# 	s1+=$1; s2+=$2; s3+=$3; cnt++;}
#
# END {
# 	printf("Avg = %.2f\t%.2f\t%.2f\n", s1/cnt, s2/cnt, s3/cnt);}
