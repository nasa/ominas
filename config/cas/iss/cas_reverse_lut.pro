;==============================================================================
; cas_reverse_lut
;
;==============================================================================
function cas_reverse_lut

 lut = cas_lut()
 reverse_lut = intarr(4096)

 for i=0, 254 do reverse_lut[lut[i]:lut[i+1]-1] = i
 reverse_lut[0] = 1
 reverse_lut[4095] = 255

; reverse_lut[lut] = bindgen(256)

 return, reverse_lut
end
;==============================================================================
