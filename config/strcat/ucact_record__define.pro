; docformat = 'rst'
;+
; :Hidden:
;-

pro ucact_record__define

 struct = $
  { ucact_record, $
	nstars:     0l, $ 
	stars:	    replicate({ucact_packed_star}, 71) $
  }

end
