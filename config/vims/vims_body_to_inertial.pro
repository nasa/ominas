;=============================================================================
;+
; NAME:
;	bod_body_to_inertial
;
;
; PURPOSE:
;	Transforms the given column vectors from the body coordinate
;	system to the inertial coordinate system.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	inertial_pts = bod_body_to_inertial(bx, body_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 	Any subclass of BODY.
;
;	body_pts:	Array (nv,3,nt) of column vectors in the body frame.
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
;	Array (nv,3,nt) of column vectors in the bx inertial frame.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
function vims_body_to_inertial, bd, v,camvecs
@core.include
 _bd = cor_dereference(bd)

 nt = n_elements(_bd)
 sv = size(v)
 nv = sv[1]

 sub = linegen3x(nv,3,nt)
 
 orients=list()
 if (isa(_bd,'ominas_camera') and ptr_valid(_bd.fn_data_p) and (n_elements(camvecs) gt 0)) then begin
  fnd=*(_bd.fn_data_p)
  inds=fnd.inds
  for i=0,n_elements(camvecs)/2-1 do begin
    dists=reform((camvecs[0,i]-inds[0,*])^2+(camvecs[1,i]-inds[1,*])^2)
    mindis=min(dists,minloc)
    orients.add,fnd.orients[*,*,minloc]
  endfor
 endif else begin
  orients.add,_bd.orient[*,0,*]
 endelse
rs=list()
foreach orient,orients,ior do begin
  
; M0 = (_bd.orient[*,0,*])[sub]
; M1 = (_bd.orient[*,1,*])[sub]
; M2 = (_bd.orient[*,2,*])[sub]
 M0 = (orient[*,0,*])[sub]
 M1 = (orient[*,1,*])[sub]
 M2 = (orient[*,2,*])[sub]


 r = dblarr(nv,3,nt,/nozero)
 r[*,0,*] = total(M0*v,2)
 r[*,1,*] = total(M1*v,2)
 r[*,2,*] = total(M2*v,2)
 rs.add,r
 endforeach
 ret=r
 foreach rr,rs,ir do ret[ir,*]=rr[ir,*]
 

 return, ret
end
;===========================================================================



