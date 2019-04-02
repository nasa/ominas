;===========================================================================
; spice_get_all_target_names
;
;  request all bodies with known radii
;===========================================================================
function spice_get_all_target_names

 cspice_gnpool, 'BODY*_RADII', 0, 128, 512, kvars, found
 if(NOT found) then return, ''

 s = str_nnsplit(kvars, '_')
 id_s = strmid(s, 4, 16)
 id = long(id_s)

 n = n_elements(kvars)-1
 names = strarr(n)
 for i=0, n-1 do $
  begin
   cspice_bodc2n, id[i], name, found 
   names[i] = name
  end

 return, names
end
;===========================================================================
