;=============================================================================
;+
; NAME:
;       dsk_get_perp
;
;
; PURPOSE:
;	Computes vectors in the direction perpendicular to the azimuthal
;	direction at a point on a disk.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       dir = dsk_get_perp(cd, dkx, p)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	dkx:	Any subclass of DISK.
;
;	p:	Point on the disk n inertial coordinates.
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (nv,3) of inertial direction vectors.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function dsk_get_perp, cd, dkd, p, uu=uu

 nv = n_elements(p)/3					; assume  nt = 1
 mm = make_array(nv, val=1d)

 cam_orient = bod_orient(cd)
 cam_pos = bod_pos(cd) ## mm
 dsk_pos = bod_pos(dkd) ## mm

 dsk_orient = bod_orient(dkd)
 zz = dsk_orient[2,*] ## mm

 dsk_pts = inertial_to_disk_pos(dkd, p)
 _dir = v_unit(bod_body_to_inertial(dkd, $
                dsk_disk_to_body(dkd, dsk_pts)))
 dir = v_cross(_dir, zz)

 dirx = v_inner(dir, cam_orient[0,*]##mm)
 diry = v_inner(dir, cam_orient[2,*]##mm)

 uu = [transpose(-diry),transpose(dirx)]
 uu = p_unit(uu)

 vv = dblarr(nv,3)
 vv[*,0] = uu[0,*]
 vv[*,2] = uu[1,*]
 vv = v_unit(vv)
 vv = bod_body_to_inertial(cd, vv)

 vv = v_cross(zz,v_cross(vv, zz))

 return, vv
end
;==============================================================================
