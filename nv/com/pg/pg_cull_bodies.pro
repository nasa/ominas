;=============================================================================
;+
; NAME:
;	pg_cull_bodies
;
;
; PURPOSE:
;	Removes (and frees) bodies in a given array.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_cull_bodies(bx, ii)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:	Array of descriptors.
;
;	ii:	Subscripts of bdies to remove.  If not undefined, no bodies are 
;		removed.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	name:	Array of names of bodies to exempt from removal.
;
;
; RETURN: NONE
;
;
; SEE ALSO:
; 	pg_select_bodies
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================
pro pg_cull_bodies, bx, sel, name=name

 ;-------------------------------------------------
 ; exempt any given names
 ;-------------------------------------------------
 if(keyword_set(name)) then $
  begin
   w = nwhere(name, cor_name(bx))
   if(w[0] NE -1) then sel = append_array(sel, w)
  end

 ;-------------------------------------------------
 ; delete deselected bodies
 ;-------------------------------------------------
 if(defined(sel)) then $
  begin
   sel = unique(sel)

   w = complement(bx, sel)
   if(w[0] NE -1) then $
    begin
     nv_free, bx[w]
     nv_message, verb=0.2, 'The following objects were deleted:'
     nv_message, verb=0.2, /anon, transpose('   ' + [cor_name(bx[w])])
    end

   if(sel[0] EQ -1) then bx = obj_new() $
   else bx = bx[sel]
  end

end
;===========================================================================
