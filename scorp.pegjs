{
  function str(s) {
    return s.join("");
  }
}

start
  = join

join
  = left:repeat ("+" / " "+) right:join { return [...left, ...right]; }
  / repeat

repeat
  = left:unit "*" right:integer { return Array(right).fill(...left); }
  / unit:unit { return [unit]; }

unit
  = "(" join:join ")" { return join; }
  / sustain:sustain { return [sustain]; }
  / note:note { return [note]; }
  / integer:integer { return [integer]; }
  / rest:rest { return [rest]; }

note
  = note:([a-g][#b]?"-1") { return str(note); }
  / note:([a-g][#b]?[0-9]?) { return str(note); }

rest
  = "-"

sustain
  = item:(note / rest) times:"_"+ { return item.repeat(times.length + 1); }

integer
  = digits:[0-9]+ { return parseInt(digits.join(""), 10); }
