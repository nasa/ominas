; docformat = 'rst'
;+
; :Hidden:
;-

pro ucact_directory__define

 struct = $
  { ucact_directory, $
	rec_start:	0l, $ 
	numrec:		0l, $
	ra_start:	lonarr(7678) $	; 7678 = RECSIZE-2
  }

end
