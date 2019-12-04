;=============================================================================
;+
; idl_v_chrono
;
; PURPOSE :
;`
;  Return a value which monotonically increases with IDL release number.
; This can be used to compare the chronological order of two IDL releases.
;
;
; CALLING SEQUENCE :
;
;    result = idl_v_chrono(release)
;
;
; ARGUMENTS
;  INPUT : release - String containing the IDL release number, 
;                    i.e; '3.6.1a'.
;
;  OUTPUT : NONE
;
;
;
; KEYWORDS 
;  INPUT : NONE
;
;  OUTPUT : NONE
;
;
;
; RETURN : See above.
;
;
;
; ORIGINAL AUTHOR : J. Spitale ; 10/94
;
; UPDATE HISTORY : 
;
;-
;=============================================================================
function idl_v_chrono, release

 pos1=strpos(release, '.', 0)
 pos2=strpos(release, '.', pos1+1)
 if(pos2 EQ -1) then pos2=strlen(release)

 left=strmid(release, 0, pos1)
 middle=strmid(release, pos1+1, pos2-pos1-1)
 right=strmid(release, pos1+pos2, strlen(release)-pos1-pos2)

 value=1000*long(left) + 100*long(middle) + long(right)

 return, value
end
;===========================================================================
