;=============================================================================
;+
; NAME:
;	map_set_west
;
;
; PURPOSE:
;	Replaces the west flag for each given map descriptor.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	map_set_west, md, west
;
;
; ARGUMENTS:
;  INPUT: 
;	md:	 Array (nt) of map descriptors.
;
;	west:	 Array (nt) of new west flags.  If not set, the flag is
;		 set to 1.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/201y
;	
;-
;=============================================================================
pro map_set_west, md, west, noevent=noevent
@core.include
 _md = cor_dereference(md)

 if(NOT defined(west)) then west = make_array(n_elements(_md), val=1)

 _md.west=west

 cor_rereference, md, _md
 nv_notify, md, type = 0, noevent=noevent
end
;===========================================================================
