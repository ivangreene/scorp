#!/usr/bin/env node

const parse = require('./parser.js');
const fs = require('fs');

for (let i = 2; i < process.argv.length; i++) {
  let file = process.argv[i];
  let parsed = parse(fs.readFileSync(file, 'utf8'));
  console.log(parsed.track);
  fs.writeFileSync(file.replace(/\.[^.]+$/, '') + '.midi',
    parsed.midi, 'binary');
}
