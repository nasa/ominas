; docformat = 'rst'
;+
; Format of the standardized star structure.
; 
; :Fields:
;    num : type=string
;       star catalog number
;    ra : type=float
;       star right ascension
;    dec : type=float
;       star declination
;    rapm : type=float
;       proper motion in ra
;    decpm : type=float
;       proper motion in dec
;    mag : type=integer
;       visual magnitude
;    px : type=integer
;       parallax
;    epochra : type=float
;       mean epoch of observation
;    epochdec : type=float
;       mean epoch of observation
;
; :Private:
;-
pro tycho2_star__define
struct = $
  { tycho2_star, $
    num:        '', $
    ra:         float(0), $
    dec:        float(0), $
    rapm:       float(0), $
    decpm:      float(0), $
    mag:        float(0), $
    px:         0, $
    epochra:    float(0), $
    epochdec:   float(0) $
  }

end