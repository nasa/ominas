;=============================================================================
;+
; NAME:
;	pg_ring_sector_box_ortho
;
; PURPOSE:
;	Allows the user to select a box to use with pg_profile_ring.
; 
; CATEGORY:
;       NV/PG
;
; CALLING SEQUENCE:
;     outline_ptd = pg_ring_sector_box_ortho()
;     outline_ptd = pg_ring_sector_box_ortho(corners)
;
;
; ARGUMENTS:
;  INPUT:
;      corners:	    Array of image points giving the corners of the box.
;		    If not given, the user is prompted to select a box. 
;
;  OUTPUT:
;	NONE
;
;
;
; KEYWORDS:
;  INPUT: 
;      win_num:     Window number of IDL graphics window in which to select
;                   box, default is current window.
;
;      restore:     Do not leave the box in the image.
;
;           p0:     First corner of box.  If set, then the routine immediately 
;                   begins to drag from that point until a button is released.
;
;        color:     Color to use for rectangle, default is !color.
;
; xor_graphics:     If set, the sector outline is drawn and erased using xor
;                   graphics instead of a pixmap.
;
;       silent:     If set, messages are suppressed.
;
;       sample:     Grid sampling, default is 1.
;
;
;  OUTPUT:
;         NONE
;
;
; RETURN: 
;      POINT object containing points on the sector outline.  The point
;      spacing is determined by the sample keyword.
;
; KNOWN BUGS:
;	The sector flips when it hits zero azimuth rather than retaining a 
;	consistent sense.
;
;
; ORIGINAL AUTHOR : J. Spitale ; 6/2005
;
;-
;=============================================================================



;=============================================================================
; pg_ring_sector_box_ortho
;
;=============================================================================
function pg_ring_sector_box_ortho, p, $
                         sample=sample, $
                         win_num=win_num, $
                         restore=restore, $
                         p0=p0, xor_graphics=xor_graphics, $
                         color=color, silent=silent

 if(NOT keyword__set(win_num)) then win_num=!window
 if(NOT keyword__set(color)) then color=!p.color
 xor_graphics = keyword__set(xor_graphics)
 if(NOT keyword_set(sample)) then sample = 1


 ;-----------------------------------------
 ; select the box
 ;-----------------------------------------
 if(NOT keyword_set(p)) then $
  begin
   if(NOT keyword__set(silent)) then $
    begin
     nv_message, 'Drag and release to define box', $
                                     name='pg_ring_sector_box_ortho', /continue
    end

   if(keyword_set(p0)) then $
     p0 = (convert_coord(/data, /to_device, double(p0[0,*]), double(p0[1,*])))[0:1,*]

   pp = tvrec(win_num, restore=restore, color=color, $
                                      p0=p0, xor_graphics=xor_graphics)
   p = (convert_coord(/device, /to_data, double(pp[0,*]), double(pp[1,*])))[0:1,*]
  end

 outline_pts = tr([tr([p[0,0],p[1,0]]), $
                   tr([p[0,1],p[1,0]]), $
                   tr([p[0,1],p[1,1]]), $
                   tr([p[0,0],p[1,1]]), $
                   tr([p[0,0],p[1,0]])])

 ;-----------------------------------------
 ; package the result
 ;-----------------------------------------
 outline_ptd = pnt_create_descriptors(points = outline_pts, desc = 'PG_RING_SECTOR_BOX_ORTHO')
 cor_set_udata, outline_ptd, 'sample', [sample]

 return, outline_ptd
end
;=====================================================================



pro test
grift, dd=dd, cd=cd, pd=pd, rd=rd

outline_ptd = pg_ring_sector_box_ortho()
outline_ptd = pg_ring_sector_box_ortho(tr([tr([0,0]),tr([1023,1023])]))

pg_draw,outline_ptd, col=ctred(), psym=-3

profile = pg_profile_ring(dd, cd=cd, dkx=rd, $
                                   outline_ptd, dsk_pts=dsk_pts, $
                                   sigma=sigma)
rads = dsk_pts[*,0]
lons = dsk_pts[*,1]

plot, rads, profile
end
