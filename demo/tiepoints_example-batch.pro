;==================================================================================
; tiepoints_example.pro
;
;  Created by Joe Spitale
;
;  Correct the pointing of one or more images based on the pointing of a 
;  reference image using tiepoints.
;
;==================================================================================
!quiet = 1
files = 'data/' + ['N1511803932_1.IMG', 'N1511803965_3.IMG']

;----------------------------------------
; read images
;----------------------------------------
dd = dat_read(files, count=ndd)


;------------------------------------
; get descriptors
;------------------------------------
cd = objarr(ndd)
pd = objarr(ndd)
for i=0, ndd-1 do cd[i] = pg_get_cameras(dd[i])
for i=0, ndd-1 do pd[i] = pg_get_planets(dd[i], od=cd[i], name=['ENCELADUS'])


;-------------------------------------------------------------------------
; select tiepoints manually
;  Use the tiepoints cursor mode to select tiepoints in each grim window.
;  When finished, grift is used to get the tiepoints.  Note the first argument
;  to grift is the grim window number shown in the title bar of each grim 
;  window.  
;-------------------------------------------------------------------------
for i=0, ndd-1 do grim, /new, dd[i], cd=cd[i], pd=pd[i], over='limb', /order, z=0.75
stop


;-------------------------------------------------------------------------
; get tiepoints from grim
;-------------------------------------------------------------------------
ptd = list(len=2)
for i=0, ndd-1 do $
 begin &$
  grift, i, tie_ptd=_ptd &$
  ptd[i] = _ptd &$
 end

;------------------------------------------------------------------------
; correct the images
;  Here we assume the pointing for the first image is correct.  If it's
;  not, then correct it before proceeding.  Since body_pts is initially 
;  undefined, they are computed on the first call to pg_tiepoints, then 
;  used subsequently to compute the offsets for each fit.  Note that the
;  reference image can also be a map projection, in which case cd[0]
;  would be the corresponding map descriptor.  
;------------------------------------------------------------------------
body_pts = 0
for i=0, ndd-1 do $
 begin &$
  tie_ptd = pg_tiepoints(cd=cd[i], bx=pd[i], ptd[i], body_pts=body_pts) &$
  if(i GT 0) then $
   begin &$
    tpcoeff = pg_ptscan_coeff(tie_ptd, fix=[2]) &$
    dxy = pg_fit(tpcoeff) &$
    pg_repoint, dxy, 0d, cd=cd[i] &$
   end &$
 end




