#!/bin/bash
# Run power.sh eight times, to record 24 hours worth of data (it seems to crash
#   after some random interval if left running for 24 hours).

for i in `seq 1 40`;
do
    # Run in background to avoid processing postponing next sample interval.
    time ./power.sh &
    date --rfc-3339=seconds

    # But still give it a few minutes to release the device in case integration
    #   interval borks things.
    sleep 1085s
done    
