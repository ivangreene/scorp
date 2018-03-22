{
  function str(s) {
    return s.join("");
  }

  function flatten(arr) {
    return arr.reduce(function(accum, curr) {
      return accum.concat(curr);
    }, []);
  }

  function parseFn(body) {
    return body.join('%%%').replace(/%%% /g, '').replace(/([,`~])%%%/g, '$1');
  }

  function execFn(fn, args) {
    let i = 0;
    return fn.replace(/x/g, function() {
      return args[i++ % args.length];
    }).split('%%%');
  }


  var runtimeVars = {};
  var metaVars = {
    tempo: 120,
    vfactor: 10,
    lengthstep: 16,
    velocity: 90,
    length: 32
  };
}

start
  = notes:join { return { notes, metaVars }; }

join // Concatenate notes or units with whitespace between them
  = left:repeat __ right:join _ { return [...left, ...right]; }
  / repeat

repeat // Repeat a unit by a number
  = left:unit _ "*" _ right:integer {
    return flatten(Array(right).fill(left));
  }
  / unit
  / assignment { return []; }
  / comment { return []; }

unit // Items between parentheses or a single note, etc.
  = fncall
  / _ "(" _ join:join _ ")" { return join; }
  / mod
  / val:retrieval ! { return typeof val === "number"; } { return val; }

/*sus // Sustain
  = mod:mod sus:"_"+ { let m = str(sus); return mod.map(n => m + n); }
  /// unit:unit sus:"_"+ { let s = str(sus); return unit.map(n => n + s); }
  */

mod // Pitch or vibrato modifications, on a note or a unit
  = mod:[`,~_;]+ note:note { return [str(mod) + note]; }
  / mod:[`,~_;]+ unit:unit { let m = str(mod); return unit.map(n => m + n); }
  // unit:unit mod:"_"+ { let m = str(mod); return unit.map(n => m + n); }
  / note:note { return [note]; }
  / rest

note // Basic note type
  = _ note:([a-g][#b]?[0-9]) { return str(note); }

rest
  = _ rest:"-"+ { return rest; }

integer // Number for variables, repitition, etc.
  = !identifier _ digits:[0-9]+ { return parseInt(str(digits), 10); }
  / val:retrieval & { return typeof val === "number"; } { return val; }

comment "comment"
  = "//" [^\n\r]* &[\n]

_ "whitespace" // Optional whitespace
  = [ \n\t\r]*

__ "whitespace+" // Necessary whitespace
  = [ \n\t\r]+

retrieval
  = id:identifier !(_"=") { return runtimeVars[id]; }

fncall
  = id:identifier "(" _ args:(join / unit) _ ")" {
      return execFn(runtimeVars[id], args);
    }

  / "{" _ body:([-x ,`~;_]+) _ "}" _ "(" _ args:(join / unit) _ ")" {
    return execFn(parseFn(body), args);
  }

assignment
  = _ id:("velocity" / "vfactor" / "lengthstep" / "tempo" / "length") _ "=" _ value:integer {
    metaVars[id] = value;
    console.log(metaVars);
    return true;
  }

  / _ id:identifier _ "=" _ value:integer {
    runtimeVars[id] = value;
    return true;
  }

  / _ id:identifier _ "=" _ value:unit {
    runtimeVars[id] = value;
    return true;
  }

  / _ id:identifier _ "=>" _ value:fnbody {
    runtimeVars[id] = value;
    return true;
  }

fnbody
  = "{" _ body:([-x ,`~;_]+) _ "}" { return parseFn(body); }

identifier "identifier"
  = id:([a-zA-Z]+[0-9a-zA-Z]*) ![0-9a-zA-Z] { return str(id); }
