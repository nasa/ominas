; docformat = 'rst'
;+
;
; Specifies the format of a standard GSC header
;
; :Private:
;
; :Fields:
;	  LEN : type=integer
;		 GSC header length I*2 
;	  VERS : type=integer
;		 GSC version I*2
;         REGION : type=integer
;                GSC region I*2
;         NOBJ : type=integer
;                Number of objects I*2
;	  AMIN : type=double
;		 Right ascension min J2000 (degrees) R*8
;         AMAX : type=double
;                Right ascension max J2000 (degrees) R*8
;         DMIN : type=double
;		 Declination J2000 min (degrees) R*8
;         DMAX : type=double
;                Declination J2000 max (degrees) R*8
;	  MAGOFF : type=double
;		 Visual Magnitude offset R*8
;         SCALE_RA : type=double
;                Right ascension scale R*8
;         SCALE_DEC : type=double
;                Right ascension scale R*8
;         SCALE_POS : type=double
;                Right ascension scale R*8
;         SCALE_MAG : type=double
;                Right ascension scale R*8
;         NPL : type=integer
;                Number of plates I*2
;         LIST : type=char
;                List of plate numbers
;
;- 
pro gsc_header__define

 struct = $
  { gsc_header, $
     LEN :    0, $ 
     VERS :   0, $ 
     REGION : 0, $
     NOBJ :   0, $ 
     AMIN :      double(0), $
     AMAX :      double(0), $
     DMIN :      double(0), $
     DMAX :      double(0), $
     MAGOFF :    double(0), $
     SCALE_RA :  double(0), $
     SCALE_DEC : double(0), $
     SCALE_POS : double(0), $
     SCALE_MAG : double(0), $
     NPL :   0, $ 
     LIST : '' $
  }

end
