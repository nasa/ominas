;=============================================================================
;+
; NAME:
;	tf_keyword_value
;
;
; PURPOSE:
;	Looks up a keyword in the data descriptor-stored keyword/value pairs.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	value = tf_keyword_value(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.  If an array, only the first element is 
;			considered.
;
;	keyword:	Keyword to look up.
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
;	Value string associated with the given keyword.  Note that transient
;	keyword/value pairs take precedence.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================



;=============================================================================
; tf_keyword_value
;
;=============================================================================
function tf_keyword_value, dd, keyword
@core.include

 _dd = cor_dereference(dd[0])

 transient_keyvals = ''
 keyvals = ''

 if(ptr_valid(_dd.tf_transient_keyvals_p)) then $
                              transient_keyvals  = *_dd.tf_transient_keyvals_p
 if(ptr_valid(_dd.tf_keyvals_p)) then keyvals = *_dd.tf_keyvals_p

 return, dat_keyword_value(keyword, transient_keyvals, keyvals, $
                    *_dd.input_transforms_p, *_dd.output_transforms_p)


end
;=============================================================================
