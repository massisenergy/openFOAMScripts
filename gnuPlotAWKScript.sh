#!/usr/bin/env bash
#sample script to plot residuals using `gnuplot`
#https://sourceforge.net/p/gnuplot/mailman/message/25432288/

################################## user input ##################################
FOAMLOG=logs/foamlog
################################################################################

awk '$0 ~ /lowerNozzleWall/ && NF==8 {
        TS++; gsub(/[\(\)]/,""); WSS_X=$6; WSS_Y=$7;
        magWSS=(WSS_X**2+WSS_Y**2)**0.5;
        print TS"\t\t"magWSS}' $FOAMLOG >| \
    logs/magWSSLowerNozzleWallvsTime;
awk '$0 ~ /middleNozzleWall/ && NF==8 {
        TS++; gsub(/[\(\)]/,""); WSS_X=$6; WSS_Y=$7;
        magWSS=(WSS_X**2+WSS_Y**2)**0.5;
        print TS"\t\t"magWSS}' $FOAMLOG >| \
    logs/magWSSMiddleNozzleWallvsTime;
awk '$0 ~ /upperNozzleWall/ && NF==8 {
        TS++; gsub(/[\(\)]/,""); WSS_X=$6; WSS_Y=$7;
        magWSS=(WSS_X**2+WSS_Y**2)**0.5;
        print TS"\t\t"magWSS}' $FOAMLOG >| \
    logs/magWSSUpperNozzleWallvsTime;

gnuplot -persist > /dev/null 2>&1 << EOF
        set title system("echo ${PWD##*/} WSS magnitude vs. Iteration")
        set xlabel "Iteration"
        set ylabel "magWSS"
        plot "logs/magWSSLowerNozzleWallvsTime" with linespoints \
            pointtype 5 pointsize 1.5 \
            linecolor rgb '#8db600', \
            \
            "logs/magWSSMiddleNozzleWallvsTime" with linespoints \
            pointtype 5 pointsize 1.5 \
            linecolor rgb '#9966cc', \
            \
            "logs/magWSSUpperNozzleWallvsTime" with linespoints \
            pointtype 5 pointsize 1.5 \
            linecolor rgb '#ffbf00'

EOF
##############################################################################

awk '/max\(mag\(U\)/ {TS++; print  TS"\t\t"$3
}' $FOAMLOG >| logs/UOutlet

gnuplot -persist > /dev/null 2>&1 << EOF
    set title system("echo ${PWD##*/} UOutlet vs. Iteration")
    set x1label "Iteration"
    set ylabel "UOutlet"
    set tics out
    set autoscale x1
    plot "logs/UOutlet" with linespoints \
        pointtype 4 pointsize 1.5 \
        linecolor rgb '#dd181f'
EOF
##############################################################################


# read -p "Enter the logpath & logname: " FOAMLOG;
# if [ $FOAMLOG -eq ]; then
    #     $FOAMLOG='logs/foamlog' &&
    #     echo "using the default path" $FOAMLOG;
    # else if [ $FOAMLOG -eq FOAMLOG ]; then
        #     echo "you entered the foamlog path as: "$FOAMLOG;
        # fi;
        # done;
