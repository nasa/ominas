;=============================================================================
;+
; NAME:
;	pg_limb_sector_linear
;
; PURPOSE:
;	Constructs a limb sector outline for use with pg_profile_image, given
;	altitude and length bounds.  The sector is rectangular, being tangent 
;	to the limb at a given azimuth.
; 
; CATEGORY:
;       NV/PG
;
; CALLING SEQUENCE:
;     outline_ptd = pg_limb_sector_line(cd=cd, gbx=gbx, alt, rim, az0)
;
;
; ARGUMENTS:
;  INPUT:
;      alt:	2-elements array giving the lower and upper altitude bounds
;		for the sector.
;
;      rim:	2-element array giving the image-coordinate cylidrical coordinates
;		of the the ends of the sector.
;
;      az0:	Azimuth of the sector tangent point.
;
;  OUTPUT:
;	NONE
;
;
;
; KEYWORDS:
;  INPUT: 
;           cd:     Camera descriptor.
;
;          gbx:     Globe descriptor giving the planet about whose limb
;                   the scan will be extracted.
;
;           gd:     Generic descriptor containig the above descriptors.
;
;       sample:     Sets the grid sampling in pixels.  Default is one.
;
;         nrim:     Total number of samples in the scan direction.  
;                   Determined by the 'sample' keyword by default.
;
;         nalt:     Total number of samples in the altitude direction.  
;                   Determined by the 'sample' keyword by default.
;
;      graphic:     If set, the sector is computed in the planetographic
;                   sense, i.e., lines of constant azimuth extend along 
;                   the local surface normal direction instead of the radial
;                   direction.
;
;
;  OUTPUT:
;             rims: Array giving azimuth at each sample.
;
;        altitudes: Array giving altitude at each sample.
;
;
; RETURN: 
;      POINT object containing points on the sector outline.  The point
;      spacing is determined by the sample keyword.  The POINT object
;      also contains the user fields 'nl' and 'nw' giving the number of points 
;      in altitude and r.
;
; KNOWN BUGS:
;	The sector flips when it hits zero azimuth rather than retaining a 
;	consistent sense.
;
;
; ORIGINAL AUTHOR : 
;	Spitale; 1/2009
;
;-
;=============================================================================
function pg_limb_sector_linear, cd=cd, gbx=_gbx, gd=gd, $
                         alt, _rim, az0, sample=sample, $
                         altitudes=altitudes, rims=rims, $
                         nrim=__nrim, nalt=__nalt, graphic=graphic
 
 if(NOT keyword_set(sample)) then sample = 1d
 rim = _rim

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(_gbx)) then _gbx = dat_gd(gd, dd=dd, /gbx)

 if(NOT keyword__set(_gbx)) then nv_message, 'Globe descriptor required.'
 __gbx = get_primary(cd, _gbx)
 if(keyword_set(__gbx[0])) then gbx = __gbx $
 else  gbx = _gbx[0,*]

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 if(n_elements(cds) GT 1) then $
            nv_message, 'No more than one camera descriptor may be specified.'


 ;--------------------------
 ; construct sector
 ;--------------------------
 _nrim = 2 & _nalt = 3

 outline_pts = get_limb_profile_outline_linear(cd, gbx, $
            alt=alt, rim=rim, nalt=_nalt, nrim=_nrim, az0=az0, graphic=graphic)

 alt_pts = outline_pts[*, _nrim+lindgen(_nalt)]
 nalt = fix(p_mag(alt_pts[*,0]-alt_pts[*,_nalt-1])/sample) + 1
 nrim = ((rim[1]-rim[0])/sample) + 1

 outline_pts = get_limb_profile_outline_linear(cd, gbx, $
            alt=alt, rim=rim, nalt=nalt, nrim=nrim, az0=az0, graphic=graphic)


 ;-------------------------------------------
 ; Return outline points
 ;-------------------------------------------
 outline_ptd = pnt_create_descriptors(points = outline_pts, desc = 'PG_LIMB_SECTOR_LINEAR')
 cor_set_udata, outline_ptd, 'nw', [nalt]
 cor_set_udata, outline_ptd, 'nl', [nrim]
 cor_set_udata, outline_ptd, 'sample', [sample]

 return, outline_ptd
end
;=====================================================================
