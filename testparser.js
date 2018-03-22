const peg = require('pegjs');
const sc = require('scribbletune');
const fs = require('fs');

let vfactor = 0.10;
let lengthstep = 16;

let parser = peg.generate(fs.readFileSync('scorp.pegjs', 'utf8'));

for (let i = 2; i < process.argv.length; i++) {
  let track = parser.parse(fs.readFileSync(process.argv[i], 'utf8'));
  track = track.map(note => {
    let level = 90;
    let length = 32;
    note = note.replace(/[,~`_;]/g, function(m) {
      switch (m) {
        case '`':
          level *= 1 + vfactor;
          break;
        case ',':
          level *= 1 - vfactor;
          break;
        case '_':
          length += lengthstep;
          break;
        case ';':
          length -= lengthstep;
          break;
      }
      return '';
    });

    return { note: note === '-' ? null : note,
             length,
             level };
  });
  console.log(track);
  sc.midi(track, process.argv[i] + '.midi');
}

  /*`

  velocity = 64
  vfactor = 10
  tempo = 120

  foo = (,(,b1 ~a3) * 2)
  bar = 9
  baz = ~(a2 foo)
  quux => { , x -- ~~x -- x- -x-- }

  ,quux(~(a3 b4) b9)

`)); */

// console.log(parser.parse(`bar=3 foo=a3 foo*bar`));
// console.log(parser.parse(`foo=a3 somevar=3 (a1 b3 foo)*somevar foo`));
