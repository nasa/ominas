;===========================================================================
;+
; NAME:
;	glb_get_cusp_points
;
;
; PURPOSE:
;	Iteratively computes the two points that occupy the limb from two 
;	different viewpoints for each given globe object.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	cusp_pts = glb_get_cusp_points(gbd, r1, r2, epsilon, niter)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	 Array (nt) of any subclass of GLOBE descriptors.
;
;	r1, r2:	 Arrays (1,3,nt) of viewer positions in the BODY frame.
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
;	Array (2, 3, nt) of cusp points in the BODY frame.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================



;===========================================================================
; _glb_get_cusp_points
;
;
;===========================================================================
function _glb_get_cusp_points, gbd, r1, r2, epsilon, niter

 nt = n_elements(gbd)

 rr = [r1, r2]

 ;-------------------------------------------
 ; Unit vectors from planet to each observer
 ;-------------------------------------------
 nn = v_unit(rr)


 ;------------------------------------------------------------------
 ; Generate first guesses at cusp points - 
 ;  Use the intersections of the planet surface with vectors formed
 ;  by intersecting the two viewing planes.
 ;------------------------------------------------------------------
 v1 = v_unit(v_cross(nn[0,*], nn[1,*]))
 v2 = -v1
 vv = [v1, v2]


 ;-----------------------------------------------------------------
 ; Iterate to find the actual cusps.
 ;-----------------------------------------------------------------
 rcusp_body = dblarr(2,3)

 for i=0, 1 do $
  begin
   v = vv[i,*]
   done = 0
   nit = 0
   correct = 1d
   while(NOT done) do $
    begin
     ;---------------------------------
     ; compute current cusp points
     ;---------------------------------
     rcusp_surface = glb_body_to_globe(gbd, v)
     rcusp_surface[*,2] = 0d
     rcusp_body[i,*] = glb_globe_to_body(gbd, rcusp_surface)

     rnorm_body = glb_get_surface_normal(gbd, rcusp_surface)


     ;---------------------------------
     ; compute residuals
     ;---------------------------------
     done = 1
     for j=0, 1 do $
      begin
       x = rcusp_body[i,*] - rr[j,*]
       x_mag = v_mag(x)
       res = v_inner(rnorm_body, x) / x_mag

       ;---------------------------------
       ; make new guesses if necessary
       ;---------------------------------
       offset = 0.5d*res * correct

       if(abs(res) GT epsilon) then $
        begin
         done = 0

         sign = -1d
         if(v_inner(v_cross(vv[i,*], nn[1-j,*]), nn[j,*]) GT 0) then sign = 1d

         v = v_rotate_11(v, sign*nn[1-j,*], [offset], [sqrt(1d - offset^2)])
        end
      end

     nit = nit + 1
     if(nit GE niter) then done = 1
     if(nit mod (niter/4d) EQ 0) then correct = 0.5d*correct
    end
  end


 return, rcusp_body
end
;===========================================================================




;===========================================================================
; glb_get_cusp_points
;
; r is array (1,3,nt) of column vectors giving the position of the viewer.
; gbd is array of nt globe descriptors.  Result is array (2,3,nt)
; of cusp column vectors.
;
;===========================================================================
function glb_get_cusp_points, gbd, r1, r2, epsilon, niter
@core.include
 

 if(NOT keyword_set(epsilon)) then epsilon = 1d-3
 if(NOT keyword_set(niter)) then niter = 1000

 nt = n_elements(gbd)
 result = dblarr(2, 3, nt, /nozero)

 for t=0, nt-1 do $
  result[*,*,t] = _glb_get_cusp_points(gbd[t], r1[*,*,t], r2[*,*,t], epsilon, niter)

 return, result
end
;===========================================================================
