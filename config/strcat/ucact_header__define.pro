; docformat = 'rst'
;+
; :Hidden:
;-

pro ucact_header__define

 struct = $
  { ucact_header, $
	id:		      bytarr(8), $
	version:	  0l, $
	name:		    bytarr(8), $
	equinox:	  0l, $
	SCDMIN:		  0l, $
	SCDMAX:		  0l, $
	DEGREC:		  0l, $
	RECSIZE:	  0l, $
	MAXBND:		  0l, $
	DIRBEG:		  0l, $
	unused:		  bytarr(28), $
	NHDLIN:		  0l, $
	comment:	  bytarr(2480) $
  }

end
