#!/usr/bin/env bash
#sample script to plot residuals using `gnuplot`

# foamLog logs/*.foamlog > /dev/null
# foamLog *foamlog > /dev/null
FOAMLOG=logs/foamlog
# read -p "Enter the logpath & logname: " foamlog && \
foamLog $FOAMLOG >| /dev/null
gnuplot -persist > /dev/null 2>&1 << EOF
        set logscale y
        set title "Residual vs. Iteration"
        set xlabel "Iteration"
        set ylabel "Residual"
        plot "logs/Ux_0" with lines,\
              "logs/Uy_0" with lines,\
              "logs/Uz_0" with lines,\
              "logs/p_0" with lines
EOF
