; docformat = 'rst'
;+
; :Description:
;    Given a string containing a comma-separated sequence of values, returns
;    a string array with each value. Values can be quoted strings, in which case
;    they can contain a comma inside them (which is why this routine exists, otherwise
;    strsplit could do the job). Either type of quote can be used to mark the strings, but
;    each string must be finished with the same type of quote it started.
;
; :Returns:
;    A string array where each element is one of the comma-separated fields in str. 
;
; :Params:
;    str : in, required
;      The string containing the comma-separated fields.
;    count : out, optional
;      The number of fields found. 
;
; :Examples:
; 
;   Split '"1,2","2","3","4"' into its fields::
; 
;     print,pp_extractfields('"1,2","2","3","4"',count),count   
;     ;"1,2" "2" "3" "4"
;     ;       4
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com)
;-
function pp_extractfields,str,count
compile_opt idl2

ret=strsplit(str,',',/extract,count=count)
if (strpos(str,'"') eq -1) && (strpos(str,"'") eq -1)  then return,strtrim(ret,2) ;If there are no quoted strings, strsplit does the job
;Find if any quoted strings contained a ',', and if so, rejoin them
i=0
while (i lt count) do begin
  tmp=strtrim(ret[i],2)
  sjoin=0
  if (strpos(tmp,'"') eq 0) && (strpos(tmp,'"',/reverse_search) ne strlen(tmp)-1) then sjoin=1
  if (strpos(tmp,"'") eq 0) && (strpos(tmp,"'",/reverse_search) ne strlen(tmp)-1) then sjoin=1
  if sjoin then begin ;If joining to the next is necessary
    ret[i]+=','+ret[i+1]
    ret=i eq (count-2) ? ret[0:i] : [ret[0:i],ret[i+2:*]]
    count-- 
  endif else ret[i++]=tmp
endwhile
count=n_elements(ret)

return,ret
end
