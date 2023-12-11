#!/bin/bash

start=0
step=20
mkdir -p out
i=0
while true; do
    mkdir -p tmp
    echo $(( start * 10 + i * step * 10 )) > frames-start.txt
    typst compile visual.typ --format=png tmp/frame-{n}.png --ppi=50 || exit 42
    if [ -f "tmp/frame-1.png" ]; then
        padded_out=$(printf "%06d" "$(( start + i * step + 1 ))")
        mv "tmp/frame-1.png" "out/frame-$padded_out.png"
        break
    fi
    for j in {1..20}; do
        padded_in=$(printf "%02d" "$j")
        padded_out=$(printf "%06d" "$(( start + i * step + j ))")
        mv "tmp/frame-$padded_in.png" "out/frame-$padded_out.png"
    done
    rm -rf tmp
    i=$(( i + 1 ))
done

ffmpeg -framerate 60 -pattern_type glob -i 'out/*.png' -c:v libx264 -pix_fmt yuv420p out.mp4
