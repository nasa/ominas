;==============================================================================
; write_povray
;
;==============================================================================
pro write_povray, filename, verts, faces


 ;-------------------------------------------
 ; package vertices and faces
 ;-------------------------------------------
 nverts = n_elements(verts[*,0])
 nfaces = n_elements(faces[*,0])

 vlines = make_array(nverts, val='v ') + $
           strtrim(verts[*,0]/1000d, 2) + ' ' + $
           strtrim(verts[*,1]/1000d, 2) + ' ' + $
           strtrim(verts[*,2]/1000d, 2)

 flines = make_array(nfaces, val='f ') + $
           strtrim(faces[*,0]+1, 2) + ' ' + $
           strtrim(faces[*,1]+1, 2) + ' ' + $
           strtrim(faces[*,2]+1, 2)


 ;-------------------------------------------
 ; write file
 ;-------------------------------------------
 write_txt_file, filename, [vlines, flines]


end
;==============================================================================


; write_povray, '~/tmp/golevka1.obj', verts, faces
