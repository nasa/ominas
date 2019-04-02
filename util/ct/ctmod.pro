;========================================================================
;+
; NAME:
;       ctmod
;
; PURPOSE:
;       To get display visual type (8 or 24 bit) and reserve a number of
;       colors for overlay plotting in the lookup table (for 8 bit).
;
;
; CATEGORY:
;       UTIL/CT
;
;
; CALLING SEQUENCE:
;       cdmod, visual=visual, top=top

; ARGUMENTS:
;  INPUT:
;       NONE
;
;  OUTPUT:
;    visual:  Number of planes in idl image device.
;
;       top:  New top of lookup table available to image display.
;
;
;  SIDE EFFECTS:
;	The system variable !ct_top is set to the value of the 'top' output 
;	above.
;
;-
;========================================================================
pro ctmod, visual=visual, top=top, _r, _g, _b, bw=bw, color=color, ct=ct
@ct_block.common

 if(keyword_set(bw)) then _bw = 1-_bw
 if(defined(color)) then _color = color

 if(defined(ct)) then $
  begin
   loadct, ct
   tvlct, /get, _r, _g, _b
  end

 ;----------------------
 ; detect visual type
 ;----------------------
 visual = round(alog(!d.n_colors)/alog(2))
 if(!d.name EQ 'PS') then visual = 24

 if(visual LT 8 AND visual GT 1) then visual = 8

 if(visual GT 24) then message, 'Unsupported visual.'
 
 if(visual EQ 24) then device, decomposed = 1

 if(defined(_r)) then $
  begin
   _ctuser_r = append_array(_ctuser_r, _r)
   _ctuser_g = append_array(_ctuser_g, _g)
   _ctuser_b = append_array(_ctuser_b, _b)
  end

 if(visual NE 8) then return


 ;-------------------
 ; get current table
 ;-------------------
 catch, errno					; catch graphics device error
 if(errno NE 0) then $
  begin
   if(errno EQ -366) then return
  end
 tvlct, r, g, b, /get

 ;----------------------------------------
 ; compress table and add plotting colors
 ;----------------------------------------
 n = n_elements(r)
 nuser = n_elements(_ctuser_r)

;nuser=0
 n1 = n - 8 - nuser

 sub = round(lindgen(n1)*(float(n)/float(n1)))
 r1 = r[sub]
 g1 = g[sub]
 b1 = b[sub]

 if(nuser GT 0) then $
  begin
   r1 = [r1, _ctuser_r]
   g1 = [g1, _ctuser_g]
   b1 = [b1, _ctuser_b]
  end

 r1 = [r1, 0,   0,   255, 0,    0, 255, 255, 255]
 g1 = [g1, 0,   255, 0,   255,  0, 255, 0,   255]
 b1 = [b1, 0,   255, 0,   0,  255, 0,   255, 255]

 ;-------------------
 ; load new table
 ;-------------------
 tvlct, r1, g1, b1

 ;-------------------
 ; compute top index
 ;-------------------
 tvlct, r, g, b, /get
 n = n_elements(r)
 top = n1 - 2

 defsysv, '!ct_top', top 

end
;========================================================================

