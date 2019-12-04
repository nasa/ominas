;==============================================================================
; cas_query_lut
;
;  Adapted from code contributed by Daren Wilson.
;
;==============================================================================
function cas_query_lut, label

 q = vicgetpar(label, 'DATA_CONVERSION_TYPE')
 if(size(q, /type) EQ 2) then q = vicgetpar(label, 'CONVERSION_TYPE')
 if(size(q, /type) NE 2) then if(q EQ 'TABLE') then return, 1

 return, 0
end
;==============================================================================
