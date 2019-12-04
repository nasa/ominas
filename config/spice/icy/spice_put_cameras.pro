;==================================================================================
; spice_put_cameras
;
;==================================================================================
function spice_put_cameras, sc, inst, plat, ref, fname, comment, $
                        et, exp, pos, vel, $
                        cmat, _avel

 ;-------------------------------------
 ; open new kernel file
 ;-------------------------------------
 cspice_ckopn, fname, fname, 0, handle


 ;-------------------------------------
 ; get continuous spacecraft times
 ;-------------------------------------
 tmin = et - exp/2d
 tmax = et + exp/2d
 cspice_sce2c, sc, tmin, sclk0
 cspice_sce2c, sc, tmax, sclk1
 sclk0 = sclk0 - 1
 sclk1 = sclk1 + 1
 sclk = [sclk0, sclk1]


 ;-------------------------------------
 ; write type-3 c kernel
 ;-------------------------------------
 split_filename, fname, dir, segid, ext
;stop
 segid = strmid(segid, 0, 40)			; max segid length
 avel = transpose(_avel##make_array(2, val=1d))

 id = inst
 pmat = cmat
 if(keyword_set(plat)) then $
  begin
   id = plat

   cspice_frmnam, inst, name_inst
   cspice_frmnam, plat, name_plat
   cspice_pxform, name_inst, name_plat, et, _M

   M = dblarr(3,3, /nozero)
   M[0,*] = -_M[0,*]
   M[1,*] = -_M[1,*]
   M[2,*] = _M[2,*]

   pmat = M ## cmat
  end

 cspice_m2q, pmat, q
 quat = q#make_array(2, val=1d)

 cspice_ckw03, handle, $
           sclk0, $
           sclk1, $
           id, $
           ref, $
           1, $
           segid, $
           sclk, $
           quat, $
           avel, $
           [sclk0]


 ;-------------------------------------
 ; add comment if given
 ;-------------------------------------
 if(keyword_set(comment)) then $
   if(routine_exists('cspice_dafac')) then $
                cspice_dafac, handle, max(strlen(comment)), [comment]


 ;-------------------------------------
 ; close ck file
 ;-------------------------------------
 cspice_ckcls, handle


 return, 0
end
;==================================================================================



