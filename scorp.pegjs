{
  function str(s) {
    return s.join("");
  }

  function flatten(arr) {
    return arr.reduce(function(accum, curr) {
      return accum.concat(curr);
    }, []);
  }

  var runtimeVars = {};
  var metaVars = {};
}

start
  = join

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
      let i = 0;
      return runtimeVars[id].replace(/x/g, function() {
        return args[i++ % args.length];
      }).split('%%%');
    }

assignment
  = _ id:("velocity" / "vfactor" / "tempo") _ "=" _ value:integer {
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
  = "{" _ body:([-x ,`~]+) _ "}" {
    return body.join('%%%').replace(/%%% /g, '').replace(/([,`~])%%%/g, '$1');
  }

identifier "identifier"
  = id:([a-zA-Z]+[0-9a-zA-Z]*) ![0-9a-zA-Z] { return str(id); }
