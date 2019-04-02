;==============================================================================
; cas_iss_query_lut
;
;  Adapted from code contributed by Daren Wilson.
;
;==============================================================================
function cas_iss_query_lut, label

 ;Test if JSON label (w10n)
 first_char = strmid(label, 0, 1)
 if(first_char EQ '[' OR first_char EQ '{') then begin
   jlabel = json_parse(label, /tostruct)
   q = jlabel.PROPERTY[1].DATA_CONVERSION_TYPE
   if(q EQ 'TABLE') then return, 1
   return, 0
 endif

 q = vicgetpar(label, 'DATA_CONVERSION_TYPE')
 if(size(q, /type) EQ 2) then q = vicgetpar(label, 'CONVERSION_TYPE')
 if(size(q, /type) NE 2) then if(q EQ 'TABLE') then return, 1

 return, 0
end
;==============================================================================
