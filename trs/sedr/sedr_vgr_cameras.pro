;===========================================================================
;+
; NAME:
;	sedr_vgr_cameras
;
;
; PURPOSE:
;	To be called by Voyager SEDR input translator or similar procedure to
;	convert sedr values to an nv camera descriptor
;
; CATEGORY:
;	UTIL/SEDR
;
;
; RESTRICTIONS:
;	By default, Voyager values return B1950 co-ordinates
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle, 1/1999
;
;-
;===========================================================================
function sedr_vgr_cameras, dd, sedr, geom, j2000=j2000, $
         n_obj=n_obj, dim=dim, status=status


 status=0
 n_obj=1  ; SEDR returns only one camera
 dim = [1]

 ;--------------------------
 ; cam_name
 ;--------------------------
 names = ['VGR2_ISS_NA','VGR2_ISS_WA','VGR1_ISS_NA','VGR1_ISS_WA']
 index = (sedr.inst - 1) + 2*(sedr.scnum - 31)
 name = [names[index]]
 cam_name = reform(name, 1, n_obj,/overwrite)

 ;--------------------------
 ; cam_orient
 ;--------------------------
 cm = sedr_buildcm(sedr.alpha, sedr.delta, sedr.kappa)
 nv_cm = sedr_to_nv(cm)
 if(NOT keyword__set(j2000)) then nv_cm = b1950_to_j2000(nv_cm, /reverse)
 cam_orient = reform(nv_cm, 3, 3, n_obj, /overwrite)

 ;--------------------------
 ; cam_pos
 ;--------------------------
 pos = 1000d*transpose(double(sedr.sc_position))
 if(NOT keyword__set(j2000)) then pos = b1950_to_j2000(pos, /reverse)
 cam_pos = reform(pos, 1, 3, n_obj, /overwrite)

 ;--------------------------
 ; cam_vel
 ;--------------------------
 vel = 1000d*transpose(double(sedr.sc_velocity))
 if(NOT keyword__set(j2000)) then vel = b1950_to_j2000(vel, /reverse)
 cam_vel = reform(vel, 1, 3, n_obj, /overwrite)

 ;--------------------------
 ; cam_avel
 ;--------------------------
 avel = transpose([0d,0d,0d])
 cam_avel = reform(avel, 1, 3, n_obj, /overwrite)

 ;----------------------------------
 ; cam_exposure
 ;----------------------------------
 label = dat_header(dd)
 cam_exposure = vicgetpar(label, 'EXPOSURE_DURATION')/1000d

 ;----------------------------------
 ; cam_time -- Seconds past 1950
 ;----------------------------------
 time = [sedr_time(sedr)]
 cam_time = reform(time, 1, n_obj, /overwrite)

 ;----------------------------------
 ; cam_size
 ;----------------------------------
 nx = vicgetpar(label, 'NS')
 ny = vicgetpar(label, 'NL')
 cam_size = [nx,ny]

 ;--------------------------
 ; cam_scale
 ;--------------------------
 index = (sedr.inst - 1) + 2*(sedr.scnum - 31)
 fl = [1503.49d, 200.770d, 1500.19d, 200.465d] ; Focal length of VGR cameras
 scale = 1.d/(fl[index]*84.821428d)            ; 84.. = pixels/mm
 val = [scale, scale]
 cam_scale = reform(val, 2, n_obj, /overwrite)

 ;--------------------------
 ; cam_fn_f2i
 ;--------------------------
 f2i = ['cam_focal_to_image_linear']
 cam_fn_f2i = reform(f2i, 1, n_obj, /overwrite)

 ;--------------------------
 ; cam_fn_i2f
 ;--------------------------
 i2f = ['cam_image_to_focal_linear']
 cam_fn_i2f = reform(i2f, 1, n_obj, /overwrite)

 ;--------------------------
 ; cam_fi_data
 ;--------------------------
 cam_fi_data = nv_ptr_new()


 ;-----------------------------------
 ; geom'd image
 ;-----------------------------------
 if(geom) then $
  begin
   ;--------------------------
   ; cam_oaxis
   ;--------------------------
   oaxis = [499.,499.] 
   cam_oaxis = reform(oaxis, 2, n_obj, /overwrite)
  end $

 ;-------------------------------------------------------
 ; raw image   
 ;  Here we use initial guesses.  That's the best that
 ;  can be done before reseau marks are analyzed.
 ;-------------------------------------------------------
 else $
  begin
   ;--------------------------
   ; cam_scale
   ;--------------------------
   scale = scale / 0.85d				; just a guess!!
   val = [scale, scale]
   cam_scale = reform(val, 2, n_obj, /overwrite)

   ;--------------------------
   ; cam_oaxis
   ;--------------------------
   oaxis = [399.,399.] 
   cam_oaxis = reform(oaxis, 2, n_obj, /overwrite)

  end


 ;------------------------------
 ; create a camera descriptor
 ;------------------------------
 cd = cam_create_descriptors(n_obj, $
		gd=make_array(n_obj, val=dd), $
		name=cam_name, $
		orient=cam_orient, $
		avel=cam_avel, $
		pos=cam_pos, $
		vel=cam_vel, $
		time=cam_time, $
		exposure=cam_exposure, $
		fn_focal_to_image=cam_fn_f2i, $
		fn_image_to_focal=cam_fn_i2f, $
		fi_data=cam_fi_data, $
		scale=cam_scale, $
		size=cam_size, $
		oaxis=cam_oaxis)


  return, cd

end
;===========================================================================
