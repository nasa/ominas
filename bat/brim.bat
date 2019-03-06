;=============================================================================
;+
; NAME:
;	brim.bat
;
;
; PURPOSE:
;	Access to brim from the unix command line.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE (from the csh prompt):
;	xidl brim.bat + files <keyvals>
;
;
; ARGUMENTS:
;  INPUT:
;	files:		One or more file specification strings following 
;			the standard csh rules.
;
;	keyvals:	Keyword-value pairs to be passed to brim.  
;
;
; RESTRICTIONS:
;	See ominas_description.txt
;
;
; EXAMPLE:
;	Note that this is intended to be set up as an xidl alias.  In csh, it 
;	would be like this:
;
;	alias brim    'xidl brim.bat +'
;
;	Using that alias, brim can be run from the csh prompt as in this 
;	example:
;
;	brim 'N*.IMG' 
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	grim.bat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; sometime before 5/2005
;	
;-
;=============================================================================
!quiet = 1

___argv = bat_parse_argv(___keys, ___val_ps, $
                           list=___list, path=___path, samp=___samp, sel=___sel)
___filespecs = bat_expand(___argv, ___list, ___path, ___samp, ___sel)
if(keyword_set(___filespecs)) then ___files = findfiles(___filespecs, /tolerant)

call_procedure, 'brim',___files,_extra=pp_build_extra(___keys,___val_ps)
;=============================================================================

