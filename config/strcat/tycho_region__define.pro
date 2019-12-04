; docformat = 'rst'
;+
;
; Format of the Tycho (1) region index.
;
; :Private:
; 
; :Fields:
;    RA_LOW : type=float
;       RA low region boundry (degrees) R*4
;    RA_HI : type=float
;       RA hi region boundry (degrees) R*4
;    DEC_LO : type=float
;       DEC low region boundry (degrees) R*4
;    DEC_HI : type=float
;       DEC low region boundry (degrees) R*4
;    REG_NO : type=integer
;       GSC/Tycho region number (1-9537) I*2
;-
pro tycho_region__define

 struct = $
  { tycho_region,  $
     RA_LOW:  0.0, $
     RA_HI:   0.0, $
     DEC_LO:  0.0, $
     DEC_HI:  0.0, $
     REG_NO:  0    $
  }

end
