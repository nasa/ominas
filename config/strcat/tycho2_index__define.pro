; docformat = 'rst'
;+
; Format of one line in TYCHO-2 index.dat
;
; :Fields:
;    rec_t2 : type=long
;       Tycho-2 record of first star in GSC region
;    rec_s1 : type=long
;       Suppl-1 record of first star in GSC region
;    RAmin : type=float
;       smallest RA in region
;    RAmax : type=float
;       largest RA in region
;    DEmin : type=float
;       smallest DEC in region
;    DEmax : type=float
;       largest DEC in region
;
; :Private:
;-
pro tycho2_index__define

struct = $
	{ tycho2_index, $
	  rec_t2:	  0l, $
	  rec_s1:	  0l, $
	  RAmin:	  float(0), $
	  RAmax:	  float(0), $
	  DEmin:	  float(0), $
	  DEmax:	  float(0)  $
  }

  end