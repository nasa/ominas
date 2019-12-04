; docformat = 'rst'
;+
; Format of the standardized star catalog record for gsc2.
;
; :Private:
;
; :Fields:
;     GSC2_ID : type=integer
;        GSC2 ID number I*4
;     RA_DEG : type=float
;        Right ascension J2000 (degrees) R*4
;     DEC_DEG : type=float
;        Declination J2000 in degrees R*4
;     RApm : type=float
;        RA proper motion in milliarcseconds/year R*4
;     DECpm : type=float
;        DEC proper motion in milliarcseconds/year R*4
;     MAG : type=float
;        Visual Magnitude R*4
;-
pro gsc2_record__define

 struct = $
  { gsc2_record, $
     GSC2_ID:     0l, $
     RA_DEG:      float(0), $
     DEC_DEG:     float(0), $
     RApm:        float(0), $
     DECpm:       float(0), $
     MAG:         float(0)  $
  }

end
