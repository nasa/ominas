; docformat = 'rst'
;+
;
; Format of a record in the SAO catalog
;
; :Private:
;
; :Fields:
;	RA : type=float
;		Right ascension EME1950 (radians) R*4
;	RApm : type=float
;		Annual pm in RA in sec of time R*4
;	Dec : type=float
;		Declination EME1950 in radians R*4
;	Decpm : type=float
;		Annual pm in Dec in sec of arc R*4
;	Mag : type=float
;		Visual magnitude (null if 99.9) R*4
;	Name : type=bytarr(13)
;		Star name
;	Sp : type=bytarr(3)
;		Spectral type("+++"=multiple) A3
;
;-
pro sao_record__define

 struct = $
  { sao_record, $
     RA:      float(0), $
     RApm:    float(0), $
     Dec:     float(0), $
     Decpm:   float(0), $
     Mag:     float(0), $
     Name:    bytarr(13), $
     Sp:      bytarr(3) $
  }

end
