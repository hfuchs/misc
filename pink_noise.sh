#!/bin/sh
# 2011-11-14, Adapted by Hagen Fuchs <hagen.fuchs@physik.tu-dresden.de>
# from <http://unreasonable.org/node/303>
#
# Takes the original pink-noise script and adds a bit of naive oscillation.

trap 'kill $play_id; exit' EXIT INT

$( play -q -t sl - synth '7:00:00' pinknoise \
    band -n 1800 500 tremolo 1 .1 < /dev/zero ) &
play_id=$!

while true; do
    for i in $(seq 255 -2 200; seq 200 2 255); do
        sleep 0.1
        amixer -q set 'PCM' $i
    done
done

