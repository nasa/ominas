;=============================================================================
;+
; NAME:
;	pg_reposition
;
;
; PURPOSE:
;	Modifies the body position based on the given offset and observer.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_reposition, bx=bx, dv
;	pg_reposition, bx=bx, dv, od=od
;
;
; ARGUMENTS:
;  INPUT:
;	dv:		Array (nv,3,nt) specifying the translation vector.
;			The components are assumed to be given wrt to the 
;			inertial frame unless od is given.  In that case
;			dv is interpreted as a vector in the body frame of od.
;
;			For convenience, if dv is given in the nonstandard form
;			of a 3-element array, it is reinterpreted as a column 
;			vector (1,3).
;
;			If ref_bx is given, then dv is interpreted as a distance
;			and the direction is constructed from one of the directional
;			keywords below.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	bx:	Array (nt) of body descriptors to translate.
;
;	od:	Observer descriptor; specifies the body frame for the
;		translation vector.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	ref_bx:	Body descriptor giving reference position for directional
;		keywords.
;
;	toward:	Body should be translated toward ref_bx (default).
;
;	away:	Body should be translated away from ref_bx.
;
;	at:	Body should be placed at the position of ref_bx.
;
;	along:	Index of bx axis along which to translate.
;
;	absolute:
;		If set, dv is taken as an absolute position instead of an
;		offset.	
;
;
;  OUTPUT:
;	NONE.
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	pg_reposition modifies bx and adds its name to the task list of each given
;	descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2007
;	
;-
;=============================================================================
pro pg_reposition, bx=bx, _dv, od=od, ref_bx=ref_bx, dd=dd, gd=gd, $
               toward=toward, away=away, at=at, along=along, absolute=absolute


 ;---------------------------------------------
 ; use directional keywords if scalar dv given
 ;---------------------------------------------
 if(keyword_set(ref_bx)) then $
  begin
   if(keyword_set(_dv)) then distance = _dv

   dv = bod_pos(ref_bx) - bod_pos(bx)
   if(defined(along)) then $
    begin
     dv = (bod_orient(bx))[abs(along),*,*]
     if(along LT 0) then away = 1
    end

   if(keyword_set(at)) then distance = v_mag(dv) $
   else if(keyword_set(away)) then dv = -dv

   dv = distance#make_array(3,val=1d) * v_unit(dv)
  end $
 else $
  begin
   dv = _dv
   dim = size(dv, /dim)
   if(n_elements(dim) EQ 1) then dv = transpose([dv])
  end


 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)


 ;-----------------------------------------------
 ; transform from body frame if relevant
 ;-----------------------------------------------
 if(keyword_set(od)) then dvv = bod_body_to_inertial(od, dv) $
 else dvv = dv


 ;-----------------------------------------------
 ; reposition
 ;-----------------------------------------------
 if(keyword_set(absolute)) then bod_set_pos, bx, dvv $
 else bod_set_pos, bx, bod_pos(bx) + dvv


 cor_add_task, bx, 'pg_reposition'
end
;=============================================================================



