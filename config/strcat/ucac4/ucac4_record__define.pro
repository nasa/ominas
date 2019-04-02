; docformat = 'rst'
;+
; :Hidden:
;-

pro ucac4_record__define

 struct = $
  { ucac4_record, $
	ra:		0l,  $
	spd:		0l,  $
	magm:		0,   $
	maga:		0,   $
	sigmag:		0b,  $
	objt:		0b,  $
	cdf:		0b,  $

	sigra:		0b,  $
	sigdc:		0b,  $
	na1:		0b,  $
	nu1:		0b,  $
	cu1:		0b,  $

	cepra:		0,   $
	cepdc:		0,   $
	pmrac:		0,   $
	pmdc:		0,   $
	sigpmr:		0b,  $
	sigpmd:		0b,  $

	pts_key:	0l,  $
	j_m:		0,   $
	h_m:		0,   $
	k_m:		0,   $
	icgflg:		bytarr(3),  $
	e2phmo:		bytarr(3),  $

	apasm:		intarr(5),   $
	apase:		bytarr(5),  $
	gcflg:		0b,  $

	icf:		lonarr(1),  $

	leda:		0b,  $
	x2m:		0b,  $
	rnm:		0l,  $
	zn2:		0,   $
	rn2:		0l   $
  }
end
