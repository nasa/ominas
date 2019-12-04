;=============================================================================
; cas_format_comment
;
;=============================================================================
function cas_format_comment, od

 if(cor_isa(od[0]), 'CAMERA')) then $
        return, 'cam_orient <==> CASSINI C-matrix; lengths in km'

 if(cor_isa(od[0], 'GLOBE')) then return, 'lengths in km'

 
 return, 'No conversion performed'
end
;=============================================================================
