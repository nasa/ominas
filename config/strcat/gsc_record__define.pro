; docformat = 'rst'
;+
;
; Specifies the format of a standard GSC record
;
; :Private:
;
; :Fields:
;	  GSC_ID : type=integer
;		 GSC region ID number I*2
;	  CLASS : type=integer
;		 GSC classification number I*2
;	  RA_DEG : type=float
;		 Right ascension J2000 (degrees) R*4
;	  DEC_DEG : type=float
;		 Declination J2000 in degrees R*4
;	  MAG : type=float
;		 Visual Magnitude R*4
;
;- 
pro gsc_record__define

 struct = $
  { gsc_record, $
     GSC_ID:  0, $
     CLASS:   0, $
     RA_DEG:  float(0), $
     DEC_DEG: float(0), $
     MAG:     float(0) $
  }

end
