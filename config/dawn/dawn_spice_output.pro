;=============================================================================
;+
; NAME:
;	dawn_spice_output
;
;
; PURPOSE:
;	NAIF/SPICE output translator for Dawn.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by nv_xx_value):
;	dawn_spice_output, dd, keyword, value
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
;	dawn_spice_input
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================


;===========================================================================
; dawn_spice_write_cameras
;
;===========================================================================
pro dawn_spice_write_cameras, dd, value, ref, ck_file, reload=reload, $
                                      n_obj=n_obj, dim=dim, status=status

 cam_name = dat_instrument(dd)
 if(cam_name EQ 'DAWN_FC1') then inst=-203110l
 if(cam_name EQ 'DAWN_FC2') then inst=-203120l


 sc = -203l
 plat = -203000l

 spice_write_cameras, dd, ref, ck_file, dawn_from_ominas(value, orient_fn), $
		sc = sc, $
		inst = inst, $
		plat = plat, status=status

end
;===========================================================================



;===========================================================================
; dawn_spice_output.pro
;
; NAIF/SPICE output translator for Dawn
;
;
; key1 = ods (camera descriptor)
;
;
;===========================================================================
pro dawn_spice_output, dd, keyword, value, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords


 
 spice_output, dd, keyword, value, 'dawn', status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

end
;===========================================================================
