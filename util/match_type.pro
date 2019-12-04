;================================================================================
; match_type
;
;================================================================================
function match_type, ref, val

 reftype = size(ref, /type)
 type = size(val, /type)

 if(type EQ reftype) then return, val

 if(reftype EQ 7) then return, strtrim(val,2)

 return, double(val)
end
;================================================================================
