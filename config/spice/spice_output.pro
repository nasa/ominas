;=============================================================================
;+
; NAME:
;	spice_output
;
;
; PURPOSE:
;	Generic NAIF/SPICE output translator core.  This routine is not a 
;	OMINAS output translator; it is intended to be called by an output
;	translator that is taylored to a specific mission.  This routine 
;	works only for camera descriptors.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	spice_output, dd, keyword, value, prefix
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;			Only 'CAM_DESCRIPTORS' is recognized and the routine
;			[prefix]_spice_write_cameras is called.
;
;	value:		The data to write.
;
;	prefix:		String giving a prefix to use in contructing the names
;			of the input function:
;
;			  [prefix]_spice_write_cameras
;
;			This function is a wrapper that prepares the relevant
;			inputs for a specific mission and calls
;			spice_write_cameras to write a C-kernel.  See
;			cas_spice_output for an example of how to write such
;			a function.
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
;	klist:		Name of a file giving a list of SPICE kernels to use.
;			If no path is included, the path is taken from the 
;			NV_SPICE environment variable.
;
;	ck_out:		String giving the name of the new C-kernel to write.
;			If the file base name is 'auto', then the name is
;			taken from the core name property of the data descriptor,
;			with the extension '.bc' added.
;
;	reload:		If set, new kernels are loaded, as specified by the
;			klist keyword.
;
;
;  ENVIRONMENT VARIABLES:
;	NV_SPICE_KER:	Directory containing the kernel list file.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	spice_input
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================
pro spice_output, dd, keyword, value, prefix, inst, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 status=0

 inst_prefix = prefix
 if(keyword_set(inst)) then inst_prefix = inst_prefix + '_' + inst

 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------
 ref = dat_keyword_value(dd, 'ref')
 if(NOT keyword__set(ref)) then ref = 'j2000'

 j2000 = dat_keyword_value(dd, 'j2000')
 if(keyword__set(j2000)) then ref = 'j2000'

 b1950 = dat_keyword_value(dd, 'b1950')
 if(keyword__set(b1950)) then ref = 'b1950'

 ck_file = dat_keyword_value(dd, 'ck_out')
 if(NOT keyword__set(ck_file)) then $
  begin
   nv_message, verb=0.9, $
              'No C-kernel file generated because ck_file not specified.'
   status = -1
   return
  end
 ck_dir = (file_search(file_dirname(ck_file)))[0]
 ck_name = file_basename(ck_file)
 if(strupcase(ck_name) EQ 'AUTO') then ck_name = cor_name(dd) + '.bc'
 ck_file = ck_dir + path_sep() + ck_name


 reload = dat_keyword_value(dd, 'reload')



 ;-----------------------------------------------
 ; observer descriptor passed as key1
 ;-----------------------------------------------
; if(keyword__set(key1)) then ods = key1 $
; else nv_message, 'No observer descriptor.'


 ;--------------------------
 ; match keyword
 ;--------------------------
 if(keyword NE 'CAM_DESCRIPTORS') then $
  begin
   status = -1
   return
  end


 call_procedure, inst_prefix + '_spice_write_cameras', $
                  dd, value, ref, ck_file, n_obj=n_obj, dim=dim, status=status

; if(keyword__set(klist_tmp)) then delete_file, klist

end
;===========================================================================
