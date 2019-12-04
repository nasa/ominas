; docformat = 'rst'
;+
; :Hidden:
;-

pro ucac4_record__define

 struct = $
  { ucac4_record, $
	ra:			   0l,  $
	spd:		   0l,  $
	magm:		   0,   $
	maga:		   0,   $
	sigmag:		 0b,  $
	objt:		   0b,  $
	cdf:		   0b,  $

	sigra:		 0b,  $
	sigdc:		 0b,  $
	na1:		   0b,  $
	cu1:	  	 0b,  $

	cepra:		 0,   $
	cepdc:		 0,   $
	pmrac:		 0,   $
	pmdc:		   0,   $
	sigpmr:		 0b,  $
	sigpmd:		 0b,  $

	id2m:		   0l,  $
	jmag:		   0,   $
	hmag:		   0,   $
	kmag:		   0,   $
	icgflg0:	 0b,  $
	icgflg1:   0b,  $
	icgflg2:   0b,  $
	e2phmo0:   0b,  $
	e2phmo1:   0b,  $
	e2phmo2:   0b,  $

	apasm0:		 0,   $
	apasm1:    0,   $
	apasm2:    0,   $
	apasm3:    0,   $
	apasm4:    0,   $
	apase0:		 0b,  $
	apase1:    0b,  $
	apase2:    0b,  $
	apase3:    0b,  $
	apase4:    0b,  $
	gcflg:		 0b,  $

	icf:		   0l,  $

	leda:		   0b,  $
	x2m:		   0b,  $
	rnm:		   0l,  $
	zn2:		   0,   $
	rn2:		   0l   $
  }
end