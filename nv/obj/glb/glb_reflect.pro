;===========================================================================
;+
; NAME:
;	glb_reflect
;
;
; PURPOSE:
;	Computes the reflection of rays with GLOBE objects.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	int_pts = glb_reflect(gbd, v, r)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	Array (nt) of any subclass of GLOBE descriptors.
;
;	v:	Array (nv,3,nt) giving observer positions in the BODY frame.
;
;	r:	Array (nv,3,nt) giving point positions in the BODY frame.
;
;	epsilon:	Controls the precision of the iteration.  Default
;			is 1d-3.
;
;	niter:	Maximum number of iterations, default is 1000
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (nv,3,nt) of points in the BODY frame.  Zero 
;	vector is returned for points with no solution.
;
;
; STATUS:
;	Not well tested
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2016
;	
;-
;===========================================================================
function glb_reflect, gbd, v, r, hit=hit, miss=miss, all=all, $
          valid=valid, epsilon, niter
@core.include

 if(NOT keyword_set(epsilon)) then epsilon = 1d-3
 if(NOT keyword_set(niter)) then niter = 1000

 near = keyword_set(near)
 back = keyword_set(back)
 if(NOT back) then near = 1

 nt = 1
 dim = size(v, /dim)
 nv = dim[0]

 ru = v_unit(r)
 vu = v_unit(v)
 origin = dblarr(nv,3,nt)


 ;---------------------------------------------------------
 ; initial guess: assume sphere
 ;---------------------------------------------------------
 n = v_unit(ru + vu)				; sphere normal
 p = glb_intersect(gbd, origin, n)

 ;---------------------------------------------------------
 ; iterate to find accurate reflection points
 ;---------------------------------------------------------
done = 1
 done = 0
 nit = 0
 while(NOT done) do $
  begin
   ;- - - - - - - - - - - - - - - -
   ; compute trial normal
   ;- - - - - - - - - - - - - - - -
   rpu = v_unit(r-p)
   vpu = v_unit(v-p)
   nn = v_unit(rpu + vpu)

   ;- - - - - - - - - - - - - - - -
   ; compute actual normal
   ;- - - - - - - - - - - - - - - -
   n = glb_get_surface_normal(/body, gbd, p)

   ;- - - - - - - - - - - - - - - -
   ; make new guess if necessary
   ;- - - - - - - - - - - - - - - -
   dn = nn - n

   w = where(v_mag(dn) GT epsilon)
   if(w[0] EQ -1) then done = 1 $
   else $
    begin
     nw = n_elements(w)
     rad = v_mag(p)#make_array(3, val=1d)
     p[w,*,*] = p[w,*,*] + dn[w,*,*]*rad[w,*]
     p[w,*,*] = glb_intersect(gbd, origin[w,*,*], v_unit(p[w,*,*]))
    end

   nit = nit + 1
   if(nit GE niter) then done = 1
  end


 ;---------------------------------------------------------
 ; determine which reflections are valid
 ;---------------------------------------------------------
 rpu = v_unit(r-p)
 vpu = v_unit(v-p)
 nn = v_unit(rpu + vpu)
 n = v_unit(ru + vu)

 valid = make_array(nv, val=1)
 w = where(v_inner(nn, n) GT 0)
 valid[w] = 1


 if(arg_present(hit)) then hit = where(valid NE 0)
 if(arg_present(miss)) then miss = where(valid EQ 0)
 return, p
end
;===========================================================================
