; docformat = 'rst'
;+
;
; Format of a GSC region file record
;
; :Private:
;
; :Fields:
; 	  RA_LOW : type=float
;		 RA low region boundry (degrees) R*4
;	  RA_HI : type=float
;		 RA hi region boundry (degrees) R*4
;	  DEC_LO : type=float
;		 DEC low region boundry (degrees) R*4
;	  DEC_HI : type=float
;		 DEC low region boundry (degrees) R*4
;	  REG_NO : type=integer
;		 GSC region number (1-9537) I*2
;
;-
pro gsc_region__define

 struct = $
  { gsc_region, $
     RA_LOW: 0.0, $
     RA_HI: 0.0, $
     DEC_LO: 0.0, $
     DEC_HI: 0.0, $
     REG_NO: 0 $
  }

end
