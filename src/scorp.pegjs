{
  function arrToStr(arr) {
    return arr.join('');
  }

  function flatten(arr) {
    return arr.reduce(function(accum, curr) {
      return accum.concat(curr);
    }, []);
  }

  function parseFn(body) {
    return /*body.join('%%%')*/ body.replace(/%%%\s/g,
      '').replace(/([,`~_;])%%%/g, '$1');
  }

  function execFn(fn, args) {
    let i = 0;
    return fn.replace(/[1-9]/g, function(match) {
      return args[(parseInt(match) - 1) % args.length];
    }).replace(/x/g, function() {
      return args[i++ % args.length];
    }).split('%%%');
  }

  var runtimeVars = {
    tempo: 120,
    vfactor: 10,
    lengthstep: 16,
    velocity: 90,
    length: 32
  };
}

start
  = notes:join { return { notes, metaVars: runtimeVars }; }

join
  = left:repeat __ right:join _ { return [...left, ...right]; }
  / repeat

repeat
  = left:unit _ '*' _ right:integer {
    return flatten(Array(right).fill(left));
  }
  / unit
  / assignment { return []; }
  / comment { return []; }

unit
  = mod
  / modunit

modunit
  = fncall
  / _ "(" _ join:join _ ")" { return join; }
  / note
  / val:retrieval !{ return typeof val === "number"; } { return val; }

mod
  = premod:modifiers* unit:modunit postmod:modifiers* {
    return unit.map(note => arrToStr(premod.concat(postmod)) + note);
  }
/*
  / unit:modunit mod:modifiers+ {
    return unit.map(note => arrToStr(mod) + note);
  }
  */

modifiers
  = [`,~_;]

note
  = _ note:([a-g][#b]?[0-9]) { return [arrToStr(note)]; }
  / rest

rest
  = _ rest:'-'+ { return rest; }

assignment "assignment"
  = _ id:identifier _ '=' !'>' _ value:(number / integer / unit) {
    console.log(id);
    runtimeVars[id] = value;
    return true;
  }

  / _ id:identifier _ "=>" _ value:fnbody {
    runtimeVars[id] = value;
    return true;
  }

retrieval
  = id:identifier !(_"=") { return runtimeVars[id]; }

fncall "function call"
  = id:identifier "(" _ args:join _ ")" {
    return execFn(runtimeVars[id], args);
  }

  / body:fnbody _ "(" _ args:join _ ")" {
    return execFn(parseFn(body), args);
  }

fnbody "function body"
  = "{" _ body:([-x ,`~;_0-9\n\t\r]+) _ "}" { return parseFn(body.join('%%%')); }

metavar
  = "velocity" / "vfactor" / "lengthstep" / "tempo" / "length"

identifier "identifier"
  = id:([a-zA-Z]+[0-9a-zA-Z]*) { return arrToStr(flatten(id)); }

number
  = _ digits:([0-9]+ '.' [0-9]*) { return parseFloat(arrToStr(flatten(digits)), 10); }
  / val:retrieval & { return typeof val === "number"; } { return val; }
  / integer

integer
  = _ digits:[0-9]+ !"." { return parseInt(arrToStr(digits), 10); }
  / val:retrieval & {
    return (typeof val === "number") && !(val % 1);
  } { return val; }

comment
  = "//" [^\n\r]* &[\n]

_ "optional whitespace"
  = whitespace*

__ "required whitespace"
  = whitespace+

whitespace
  = [ \n\t\r]
