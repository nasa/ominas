;=============================================================================
;+
; NAME:
;	grim.bat
;
;
; PURPOSE:
;	Access to grim from a command shell.
;
;
; CATEGORY:
;	NV/BAT
;
;
; CALLING SEQUENCE (from the shell prompt):
;	ominas grim.bat -args args <keyvals>
;
;
; ARGUMENTS:
;  INPUT:
;	args:		One or more strings following the standard csh rules.
;
;	keyvals:	Keyword=value pairs to be passed to grim.  
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
;	alias grim    'ominas grim.bat -args'
;
;	Using that alias, grim can be run from the csh prompt as in this 
;	example:
;
;	grim 'N*.IMG' z=0.75
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	brim.bat
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

if(keyword__set(___files)) then $
 begin &$
  ___w = where(___files EQ '') &$
  if(___w[0] NE -1) then $
   begin &$
    for ___i=0, n_elements(___w)-1 do $
     nv_message, /con, 'File not found: ' + ___filespecs[___w[___i]] + ' skipping.' &$

    ___w = where(___files NE '') &$
    if(___w[0] EQ -1) then retall &$
    ___files = ___files[___w] &$
   end &$
 end

call_procedure,'grim',___files,_extra=pp_build_extra(___keys,___val_ps)
;=============================================================================

