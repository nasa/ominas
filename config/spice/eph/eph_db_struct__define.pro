;=============================================================================
;+
; NAME:
;	eph_db_struct__define
;
;
; PURPOSE:
;	Structure defining a record in the kernel database.
;
;
; CATEGORY:
;	CONFIG/SPICE/EPH
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;
;
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro eph_db_struct__define

 struct = $
    { eph_db_struct, $
	filename:	'', $	
	id:		0l, $	
	first:		0d, $	
	last :		0d, $	
	mtime:		0d, $	
	lbltime :	0d, $	
	installtime :	0d $	
    }


end
;===========================================================================



