#!/usr/bin/env bash

# new header, print average if exists, reset values
/[a-zA-Z]/ {
    if (cnt > 0) {
        print header;
        printf("Avg = %.10f\n", sum/cnt);
    }
    header=$0; sum=0; cnt=0;
}

# calculate average
/[0-9]/ { sum+=$2; cnt++; }

# print last average
END {
    if (cnt > 0) {
        print header;
        printf("Avg = %.10f\t%10f\n", sum, cnt);
    }
}
