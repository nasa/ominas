;=============================================================================
;+
; NAME:
;	gen_spice_input
;
;
; PURPOSE:
;	Generic NAIF/SPICE input translator. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = gen_spice_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
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
;	status:		Zero if valid data is returned.
;
;
;  TRANSLATOR KEYWORDS:
;	ref:		Name of the reference frame for the output quantities.
;			Default is 'j2000'.
;
;	j2000:		/j2000 is equivalent to specifying ref=j2000.
;
;	b1950:		/b1950 is equivalent to specifying ref=b1950.
;
;	klist:		Name of a file giving a list of SPICE kernels to use.
;			If no path is included, the path is taken from the 
;			OMINAS_SPICE_KLIST environment variable.
;
;	planets:	List of planets to for which to request ephemeris.  
;			Must be delineated by semicolons with no space.
;
;	reload:		If set, new kernels are loaded, as specified by the
;			klist and ck_in keywords.
;
;
; RETURN:
;	Data associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	gen_spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================
function gen_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 return, spice_input(dd, keyword, 'gen', '', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
