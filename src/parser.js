const peg = require('pegjs');
const midi = require('jsmidgen');
const path = require('path');
const fs = require('fs');

let parser = peg.generate(fs.readFileSync(path.resolve(__dirname, './src/scorp.pegjs'), 'utf8'));

module.exports = function parse(data) {
  let file = new midi.File();
  let midiTrack = new midi.Track();
  file.addTrack(midiTrack);

  let parsed = parser.parse(data);
  let { tempo, vfactor, lengthstep, velocity, length } = parsed.metaVars;
  vfactor /= 100;
  let metaVars = parsed.metaVars;
  console.log(metaVars);
  console.log(parsed.groups);
  let track = parsed.groups[0];
  midiTrack.setTempo(tempo);
  track = track.map((note, index) => {
    let velo = velocity;
    let len = length;
    note = note.replace(/[,~`_;]/g, function(m) {
      switch (m) {
        case '`':
          velo *= 1 + vfactor;
          break;
        case ',':
          velo *= 1 - vfactor;
          break;
        case '_':
          len += lengthstep;
          break;
        case ';':
          len -= lengthstep;
          break;
      }
      return '';
    });
    let chord = [];
    for (let i = 0; i < parsed.groups.length; i++) {
      if (parsed.groups[i] && parsed.groups[i][index]
          && parsed.groups[i][index] !== '-')
        chord.push(parsed.groups[i][index]);
    }
//    if (note !== '-') {
      midiTrack.addChord(0, chord, len, undefined, velo);
      // midiTrack.addNote(0, note, len, undefined, velo);
//    } else
//      midiTrack.noteOff(0, '', len);
    return { note: note === '-' ? null : note,
             len,
             velo };
  });
  return { track, midi: file.toBytes() };
}
