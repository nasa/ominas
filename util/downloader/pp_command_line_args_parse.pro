; docformat = 'rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
;+
; :Description:
;    Parses arguments provided in the command line into a more usable form:
;      simple arguments are provided as a list, in the order they were given in
;      the command line. Additionally, some arguments are parsed into a hash:
;      
;      1) -foo is parsed as a hash element with key foo and value 1
;      2) --foo=bar is parsed as a hash element with key foo and value bar
;      
; :Examples::
; 
;   Suposing the IDL session was started as::
;   
;     idl -args arg1 arg2 -key1 --key2=value1
;     
;   A call to pp_command_lne_args_parse will return::
;   
;     args=pp_command_line_args_parse()
;     help,args
;     ;** Structure <19a2d18>, 4 tags, length=16, data length=16, refs=1:
;     ;ARGCOUNT        LONG                 2
;     ;KEYCOUNT        LONG                 2
;     ;ARGUMENTS       OBJREF    <ObjHeapVar75(LIST)>
;     ;KEYWORDS        OBJREF    <ObjHeapVar73(HASH)>
;     print,args.arguments
;     ;arg1
;     ;arg2
;     print,args.keywords
;     ;key1:            1
;     ;key2: value1
;
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
function pp_command_line_args_parse
compile_opt idl2,logical_predicate
args=command_line_args(count=c)
argcount=0
keycount=0
keywords=hash()
arguments=list()
if c then begin
  i=0
  while i lt c do begin
    case 1 of
      strmatch(args[i],'--*'): begin ;if is a -- keyword
        keycount++
        if stregex(args[i],'--[[:alnum:]_]+=.+',/bool) then begin
          tmp=stregex(args[i],'--([[:alnum:]_]+)=(.+)',/extract,/subexpr)
          keywords[tmp[1]]=tmp[2]
        endif else begin
          keywords[strmid(args[i],2)]=1
        endelse
      end
      strmatch(args[i],'-*'): begin ;if is a - keyword
        keycount++
        keywords[strmid(args[i],1)]=1
      end
      else: begin
        argcount++
        arguments.add,args[i];is an argument, not a keyword
      end
    endcase
    i++
  endwhile
endif
ret={argcount:argcount,keycount:keycount,arguments:arguments,keywords:keywords}
return,ret
end
