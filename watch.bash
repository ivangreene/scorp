#!/usr/bin/env bash
nodemon -e scor,js,pegjs --exec 'node testparser.js first.scor && fluidsynth -g 2 -i "/Users/ivan/Downloads/hs_r8/HS R8 Drums.sf2" first.scor.midi'
