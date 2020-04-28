;===========================================================================
; orb_inertialize
;
;  Constructs an inertial coordinate system whose z-axis lies along the 
; given frame z axis and whose x-axis lies along the ascending node of the 
; frame x-y plane on the inertial x-y plane.  If the frame z-axis lies along
; the inertial z-axis, then the x-axis of the new system will be along
; the x-axis of the inertial system.
;
; The returned descriptor must be freed by the caller
;
;===========================================================================
function orb_inertialize, frame_bx

 epsilon = 1d-15

 nt = n_elements(frame_bx)


 orient = bod_orient(frame_bx)
 frame_xx = orient[0,*,*]				; 1 x 3 x nt
 frame_yy = orient[1,*,*]				; 1 x 3 x nt
 frame_zz = orient[2,*,*]				; 1 x 3 x nt

 inertial_bd = make_array(nt, val=bod_inertial())
 orient = bod_orient(inertial_bd)
 xx = orient[0,*,*]					; 1 x 3 x nt
 zz = orient[2,*,*]					; 1 x 3 x nt


 iframe_zz = frame_zz
 iframe_xx = xx

 dot = v_inner(frame_zz, zz)
 w = where(abs(dot-1d) GE epsilon)
 if(w[0] NE -1) then $
  iframe_xx[0,*,w] = orb_get_ascending_node(frame_bx[w], inertial_bd[w], /safe)

 iframe_yy = v_cross(iframe_zz, iframe_xx)

 iorient = orient
 iorient[0,*,*] = iframe_xx
 iorient[1,*,*] = iframe_yy
 iorient[2,*,*] = iframe_zz

 iframe_bx = nv_clone(frame_bx)
 bod_set_orient, iframe_bx, iorient

 return, iframe_bx
end
;===========================================================================
