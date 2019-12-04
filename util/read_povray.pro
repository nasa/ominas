;==============================================================================
; read_povray
;
;==============================================================================
function read_povray, filename, faces=faces

 ;-------------------------------------------
 ; read file
 ;-------------------------------------------
 tab = read_txt_table(filename)


 ;-------------------------------------------
 ; count vertices and faces
 ;-------------------------------------------
 wv = where(tab[*,0] EQ 'v')
 wf = where(tab[*,0] EQ 'f')

 nverts = (nfaces = 0)
 if(wv[0] NE -1) then nverts = n_elements(wv)
 if(wf[0] NE -1) then nfaces = n_elements(wf)
 

 ;-------------------------------------------
 ; parse vertices and faces
 ;-------------------------------------------
 verts = double(tab[wv,1:3])*1000d
 faces = long(tab[wf,1:3])-1

 return, verts
end
;==============================================================================


; verts = read_povray('data/golevka.obj', faces=faces)
