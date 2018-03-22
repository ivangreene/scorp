#!/usr/bin/env bash
nodemon -e scor,js,pegjs --exec "./src/cli.js $1.scor && fluidsynth -g 2 -i '/Users/ivan/Downloads/hs_r8/HS R8 Drums.sf2' $1.midi"
