;=============================================================================
; vgr_pixel_scale
;
;=============================================================================
function vgr_pixel_scale, cam, geom=geom

 scale = 9.2454750d-06				  ; 84.. = pixels/mm

 if(strlowcase(cam) EQ 'wa') then scale = scale * 10d

 if(keyword_set(geom)) then scale = scale * 0.85d	; this is kind of a guess

 return, [scale, scale]
end
;=============================================================================
