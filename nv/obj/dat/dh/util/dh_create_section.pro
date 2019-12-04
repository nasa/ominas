;=============================================================================
;+
; NAME:
;	dh_create_section
;
;
; PURPOSE:
;	Creates a minimal detached header section.
;
;
; CATEGORY:
;	UTIL/DH
;
;
; CALLING SEQUENCE:
;	result = dh_create_section(section)
;
;
; ARGUMENTS:
;  INPUT: 
;	section:	Name of section to create.
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
; RETURN:
;	String array in which each element is a line of the new section.
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2016
;	
;-
;=============================================================================
function dh_create_section, section

 time = get_juliandate(stime=stime, format=jdformat)

 dh_section = ['<'+ section +'>', '']
 return, dh_section
end
;=============================================================================
