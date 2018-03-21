start
  = join

join
  = left:unit "+" right:join { return `${left}${right}`; }
  / repeat

repeat
  = left:integer "*" right:number { return left * right; }
  / left:unit "*" right:number { return left.toString().repeat(right); }
  / unit

unit
  = integer
  / "(" join:join ")" { return join; }
  / letters

letters "letters"
  = letters:[a-zA-Z]+ { return letters.join(""); }
  / integer

number
  = integer
  / unit:unit { return parseInt(unit, 10); }

integer "integer"
  = digits:[0-9]+ { return parseInt(digits.join(""), 10); }
