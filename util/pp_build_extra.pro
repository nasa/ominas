; docformat = 'rst rst'
;+
; :Author: Paulo Penteado (http://www.ppenteado.net), Jul/2016
;-



;+
; :Description:
;    Creates a structure to carry keywords and values to a routine,
;    by means of the _extra keyword inheritance mechanism.
;
; :Params:
;    keys: in, required, type=strarr
;      An array of strings with the names for the keywords. The number of elements
;      and their order must match the values in the `vals` array.
;    vals: in, required, type=ptrarr
;      An array of pointers with the values corresponding to the keywords specified
;      in the `keys` array: each element is the pointer to the variable that contains
;      that keyword's value.
;      
; :Examples:
;    Create 3 keys and their values::
;    
;      keys=['arg1','arg2','arg3']
;      vals=[ptr_new([0,1,2]),ptr_new(['a','b']),ptr_new(27.8d0)]
;      
;    Pack these into an _extra-type structure::
;    
;      extra=pp_build_extra(keys,vals)
;      help,extra
;      ;** Structure <a4643e48>, 3 tags, length=48, data length=46, refs=1:
;      ;ARG1            INT       Array[3]
;      ;ARG2            STRING    Array[2]
;      ;ARG3            DOUBLE           27.800000
;      print,extra.arg1
;      ;0       1       2
;      print,extra.arg2
;      ;a b
;      print,extra,/implied
;      ;{
;      ;"ARG1": [0, 1, 2],
;      ;"ARG2": [ "a", "b"],
;      ;"ARG3": 27.800000000000001
;      ;}
;      
;    This result could then be used in a call to a function/procedure that uses
;    these keywords::
;
;      my_procedure,_extra=extra
;      
; :Requires: IDL 8.0 (could be easily rewritten to be compatible with earlier
; versions, if needed).
;
; :Author: Paulo Penteado (http://www.ppenteado.net), Jul/2016
;-
function pp_build_extra,keys,vals
compile_opt idl2,logical_predicate
ret=(!version.release ge '8.3') ? orderedhash() : hash()
if(keyword_set(keys)) then foreach key,keys,ik do ret[key]=*(vals[ik])
return,ret.tostruct()
end
