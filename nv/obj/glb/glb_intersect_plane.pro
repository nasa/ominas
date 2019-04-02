;===========================================================================
;+
; NAME:
;	glb_intersect_plane
;
;
; PURPOSE:
;	Computes the intersection of a plane with a GLOBE object.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	int_pts = glb_intersect_plane(gbd, v, n)
;
;
; ARGUMENTS:
;  INPUT: 
;	gbd:	Array (nt) of any subclass of GLOBE descriptors.
;
;	v:	Array (1,3,nt) giving plane origins in the BODY frame.
;
;	n:	Array (1,3,nt) giving the plane unit normals in the 
;		BODY frame.
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
;	Array (np,3,nt) of points in the BODY frame, np is the number of 
;	points on the curve of intersection.
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
function glb_intersect_plane, gbd, v, n, np=np


 nt = n_elements(gbd)

 if(NOT keyword_set(np)) then np = 1000


 ;---------------------------------------------
 ; closest point on plane to globe center
 ;---------------------------------------------
 ii = linegen3y(1,3,nt)
 vp = n*(v_inner(v,n))[ii]			; 1 x 3 x nt


 ;---------------------------------------------
 ; determine which planes actually intersect
 ;---------------------------------------------
 rad = (reform(v_mag(glb_intersect(gbd, dblarr(1,3,nt), n)), 2, 1, nt))[0,0,*]	; 1 x 1 x nt
 w = where(rad-reform(v_mag(vp), 1, 1, nt) GT 0)
 if(w[0] EQ -1) then return, 0
 nw = n_elements(w)

 

 ;----------------------------------------------------------
 ; construct vectors in plane, radiating from closest point
 ;----------------------------------------------------------
 vv0 = v - vp							; 1 x 3 x nt

 ww = where(v_mag(vv0) EQ 0)
 if(ww[0] NE -1) then $
  begin
   nww = n_elements(ww)

   xx = (tr([1d,0,0]))[ii]
   yy = (tr([0,1d,0]))[ii]
   zz = (tr([0,0,1d]))[ii]

   vv0 = dblarr(1,3,nt)

   nwxx = (nwyy = (nwzz = 0))
   wxx = where(v_inner(n, xx) NE 1) & if(wxx[0] NE -1) then nwxx = n_elements(wxx)
   wyy = where(v_inner(n, yy) NE 1) & if(wyy[0] NE -1) then nwyy = n_elements(wyy)
   wzz = where(v_inner(n, zz) NE 1) & if(wzz[0] NE -1) then nwzz = n_elements(wzz)

   if(nwxx GT 0) then $
    begin
     cc = colgen(1,3,nt,wxx)
     vv0[cc] = v_cross(n[cc], xx[cc])
    end
   if(nwxx LT  nt) then $
    if(nwyy GT 0) then $
     begin
      cc = colgen(1,3,nt,wyy)
      vv0[cc] = v_cross(n[cc], yy[cc])
     end
   if((nwxx + nwyy) LT  nt) then $
    if(nwzz GT 0) then $
     begin
      cc = colgen(1,3,nt,wzz)
      vv0[cc] = v_cross(n[cc], zz[cc])
     end
  end


 np2 = np/2
 _2np2 = 2*np2
 theta = dindgen(np2)/double(np2) * !dpi
 _vv0 = vv0[*,*,w] & _n = n[*,*,w]
 if(nw NE 1) then $
  begin
   _vv0 = transpose(vv0[*,*,w])
   _n = transpose(n[*,*,w])
  end
 vv = transpose(v_rotate(_vv0, _n, sin(theta), cos(theta)))	; np2 x 3 x nw
 
 ;----------------------------------------------------------
 ; find intercepts on globe surface
 ;----------------------------------------------------------
; vpp = glb_intersect(gbd, vp[*,*,w]##make_array(np2,val=1d), vv)
 vpp = glb_intersect(gbd, transpose((vp[*,*,w])[linegen3z(nw,3,np2)]), vv)
								; _2np2 x 3 x nw


 ;----------------------------------------------------------
 ; construct output array
 ;----------------------------------------------------------
 result = dblarr(_2np2,3,nt)
 result[*,*,w] = vpp 						; _2np2 x 3 x nt


 return, result
end
;===========================================================================
