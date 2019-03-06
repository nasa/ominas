;=============================================================================
;+
; NAME:
;	vgr_iss_spice_output
;
;
; PURPOSE:
;	NAIF/SPICE output translator for Voyager.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by nv_xx_value):
;	vgr_iss_spice_output, dd, keyword, value
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
;	value:		The data to write.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Camera descriptor.
;
;  OUTPUT:
;	status:		Zero unless a problem occurs.
;
;
;  TRANSLATOR KEYWORDS:
;	ref:		Name of the reference frame for the input quantities.
;			Default is 'j2000'.
;
;	j2000:		/j2000 is equivalent to specifying ref=j2000.
;
;	b1950:		/b1950 is equivalent to specifying ref=b1950.
;
;	ck_out:		String giving the name of the new C-kernel to write.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	vgr_iss_spice_input
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================


;===========================================================================
; vgr_iss_spice_write_cameras
;
;===========================================================================
pro vgr_iss_spice_write_cameras, dd, value, ref, ck_file, reload=reload, $
                                      n_obj=n_obj, dim=dim, status=status

 sc_name = vgr_parse_inst(dat_instrument(dd), cam=cam_name)
 sc = -31l
 if(sc_name EQ 'vg2') then sc = -32l
 orient_fn = 'vgr_orient_to_cmat_iss'

 plat = 0l

 inst = sc*1000 - 001l					; na camera
 if(cam_name EQ 'wa') then inst = sc*1000 - 002l	; wa camera

 plat = 0l

 spice_write_cameras, dd, ref, ck_file, vgr_from_ominas(value, orient_fn), $
		sc = sc, $
		inst = inst, $
		plat = plat, status=status

end
;===========================================================================



;===========================================================================
; vgr_iss_spice_output.pro
;
; NAIF/SPICE output translator for Voyager
;
;
; key1 = ods (camera descriptor)
;
;
;===========================================================================
pro vgr_iss_spice_output, dd, keyword, value, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords


 
 spice_output, dd, keyword, value, 'vgr', status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

end
;===========================================================================
