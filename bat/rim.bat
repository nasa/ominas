;=============================================================================
;+
; NAME:
;	rim.bat
;
;
; PURPOSE:
;	Access to rim from the unix command line.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE (from the csh prompt):
;	ominas rim.bat -args files <keyvals>
;
;
; ARGUMENTS:
;  INPUT:
;	files:		One or more file specification strings following 
;			the standard csh rules.
;
;	keyvals:	Keyword-value pairs to be passed to rim.  
;
;
; RESTRICTIONS:
;	See ominas_description.txt
;
;
; EXAMPLE:
;	Note that this is intended to be set up as an alias.  In csh, it 
;	would be like this:
;
;	alias rim    'ominas rim.bat -args'
;
;	Using that alias, rim can be run from the csh prompt as in this 
;	example:
;
;	rim 'N*.IMG' 
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	grim.bat brim.bat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; 8/2013
;	
;-
;=============================================================================
!quiet = 1

___argv = bat_parse_argv(___keys, ___val_ps, $
                           list=___list, path=___path, samp=___samp, sel=___sel)
___filespecs = bat_expand(___argv, ___list, ___path, ___samp, ___sel)
if(keyword_set(___filespecs)) then ___files = findfiles(___filespecs, /tolerant)

call_procedure,'rim',___files,_extra=pp_build_extra(___keys,___val_ps)

exit
;=============================================================================
