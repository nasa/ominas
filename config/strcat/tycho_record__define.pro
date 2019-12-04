; docformat = 'rst'
;+
;
; Format of a Tycho (1) catalog star record.
;
; :Private:
; 
; :Fields:
;     TYCHO_ID_1 : type=integer
;        GSC region ID number I*2
;     TYCHO_ID_2 : type=integer
;        Component identifier I*2
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
;
;-
pro tycho_record__define

 struct = $
  { tycho_record, $
     TYCHO_ID_1:  0, $
     TYCHO_ID_2:  0, $
     RA_DEG:      float(0), $
     DEC_DEG:     float(0), $
     RApm:        float(0), $
     DECpm:       float(0), $
     MAG:         float(0)  $
  }

end
