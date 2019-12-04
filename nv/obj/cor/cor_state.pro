;=============================================================================
;+
; NAME:
;	cor_state
;
;
; PURPOSE:
;	Builds a class tree for the given descriptor.
;
;
; CATEGORY:
;	NV/LIB/COR
;
;
; CALLING SEQUENCE:
;	cor_state, <options>
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	trace:	New value for the trace flag.
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
; 	Written by:	Spitale		5/2016
;	
;-
;=============================================================================
pro cor_state, trace=trace
@core.include

 if(defined(trace)) then core_state.trace = trace

end 
;=============================================================================
