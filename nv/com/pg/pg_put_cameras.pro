;=============================================================================
;+
; NAME:
;	pg_put_cameras
;
;
; PURPOSE:
;	Outputs camera descriptors through the translators.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_put_cameras, dd, cd=cd
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	trs:	String containing keywords and values to be passed directly
;		to the translators as if they appeared as arguments in the
;		translators table.  These arguments are passed to every
;		translator called, so the user should be aware of possible
;		conflicts.  Keywords passed using this mechanism take 
;		precedence over keywords appearing in the translators table.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Camera descriptors to output.
;
;	cam_*:		All camera override keywords are accepted.
;
;	tr_override:	String giving a comma-separated list of translators
;			to use instead of those in the translators table.  If
;			this keyword is specified, no translators from the 
;			table are called, but the translators keywords
;			from the table are still used.  
;
;  OUTPUT:
;	NONE
;
;
; SIDE EFFECTS:
;	Translator-dependent.  The data descriptor may be affected.
;
;
; PROCEDURE:
;	Camera descriptors are passed to the translators.  Any camera
;	keywords are used to override the corresponding quantities in the
;	output descriptors.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_put_planets, pg_put_rings, pg_put_stars, pg_put_maps
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	
;-
;=============================================================================
pro pg_put_cameras, dd, trs, cd=_cd, $
@cam__keywords_tree.include
@dat_trs_keywords_include.pro
		end_keywords


 if(NOT keyword_set(_cd)) then return

 ;-------------------------------------------------------------------
 ; override the specified values (name cannot be overridden)
 ;-------------------------------------------------------------------
 cd = nv_clone(_cd)

 if(defined(name)) then _name = name & name = !null
 cam_assign, cd, /noevent, $
@cam__keywords_tree.include
end_keywords
 if(defined(_name)) then name = _name


 ;-------------------------------
 ; put descriptor
 ;-------------------------------
 dat_put_value, dd, 'CAM_DESCRIPTORS', cd, trs=trs, $
@dat_trs_keywords_include.pro
                             end_keywords

 nv_free, cd
end
;===========================================================================



