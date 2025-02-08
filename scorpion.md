# Scorpion: a musical composition language

### - Multiplication may be used, similarly to how it operates on strings in Python

```
  c3 * 4
  ; Same as:
  c3 c3 c3 c3
```

These should also be able to be used with more complex compositions:

```
  (d1 c2) * 3
; Same as:
  d1 c2 d1 c2 d1 c2
```

#### - Rests will be represented as various punctuation, tbd.

Maybe including `, . | -`

Touching lines to be played concurrently. A blank line may denote a new bar.
Prefix a line with an instrument number for the midi file. Otherwise, it will
be numbered according to the line in the set.

Ex:

```
4 c3  d1
  c2  a1
```

Third C and first D will be played on instrument four, second C and first A
will be played on instrument two.

#### - Built in objects to be used in composition:
- `[a-g][#b][-1-9]`: e.g.: `a3`, `bb2`, `g#1`, `g.1`: Literal note. `.1` will follow a note to indicate -1
- `-`: rest
- `_`: sustain previous symbol (note or rest)
- `~`: New bar (grouping). May also be indicated with a hard break (2 newlines in a row). Use `~` within brackets.

Whitespace should be irrelevant, aside from newlines.

#### - Variables may be functions or bars, notes, rests, etc.

#### - An option should be available to:
  - Not extend lines (no implied rests)
  - Extend lines to the end of the longest line in their grouping with implied rests
  - Extend a line to a specified length, if shorter than this length


## Conceptual example:

Initial ideas:
- Contents within `[ ]` is evaluated immediately and assigned to that variable.
- Contents within `{ }` will be the body of a function, to be evaluated when called.

```

drum1 = [ a1 a1 -- ]
drum2 = [ (a1 -) * 2 ]

patt1 = (n, m) => { n - m m - m - - }
patt2 = (n, m) => { n n - - m - m m }

[
  drum1
  patt1(a#2, bb1)
~                     ; ~ indicates new bar
] * 3                 ; This bar will be repeated 3 times

  drum2
  patt1(a2, bb1)

```

If we had to render this by hand, it might look like this:

```
a1 a1 - -
a#2 - bb1 bb1 - bb1 - -

a1 a1 - -
a#2 - bb1 bb1 - bb1 - -

a1 a1 - -
a#2 - bb1 bb1 - bb1 - -

a1 - a1 -
a2 - bb1 bb1 - bb1 - -
```

### Another example with extended ideas

```js
velocity = 64 // Standard velocity for the track (0-127)
vfactor = 10 // Factor to raise/lower velocity by with ` or ,
tempo = 120

drum1 => { x - - x - - x - }
drum2 => { (x - x -) * 2 }

patt1 => { x - x x - - x - }
patt2 => { x - x x - x - - }

kick = a1
bass = c1 // Drums
crash = d1

[
  drum1(kick, bass) // These two parts will be played in
  patt1(a1, b2)     // parallel (part of the same bar)
  ==== // Indicates a new bar
] * 3  // Repeat this part 3 times

  ,,, drum2(kick, crash) // , indicates lower velocity, so this is
                         // 3 notches lower
  `` patt2(a2, bb1)      // ` indicates higher velocity, 2 notches higher
```

- \`: Raise velocity
- `,`: Lower velocity
- `~`: Vibrato (pitch wheel)
These may be applied to a single note (e.g. `,a1`) or a unit (e.g. `~(a1 b1)`)

```js
velocity = 64

,a1 ,,b1 // a1 will be at 58 velocity, b1 at 52
,(a1 b1) // a1 and b1 at 58 velocity
`a1 // ` // a1 at 70 velocity
~a1_ // a1 with vibrato, sustained with _
```
