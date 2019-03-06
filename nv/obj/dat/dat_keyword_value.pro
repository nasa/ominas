;=============================================================================
;+
; NAME:
;	dat_keyword_value
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
;	value = dat_keyword_value(dd, keyword)
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
;  INPUT: 
;	tr:	If set, translator keywords are searched.
;
;
;	tf:	If set, transform keywords are searched.
;
;
;	io:	If set, I/O keywords are searched.
;
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Value string associated with the given keyword.  Note that transient
;	keyword/value pairs take precedence.
;
;
; RESTRICTIONS:
;	Unless /tr, /tf, or /io are specified, this routine only works from 
;	within a translator, I/O method, or transform method because it uses 
; 	the call stack to determine which keyword list to search.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 7/2018
;	
;-
;=============================================================================



;=============================================================================
; dkv_match
;
;=============================================================================
pro dkv_match, kv, i, keyword, value=value

 if(NOT ptr_valid((*kv.keywords_p)[i])) then return
 if(NOT ptr_valid((*kv.values_p)[i])) then return

 keywords = (*(*kv.keywords_p)[i])
 values = (*(*kv.values_p)[i])

 w = where(strupcase(keywords) EQ strupcase(keyword))

 if(w[0] EQ -1) then return

 value = values(w[0])
end
;=============================================================================



;=============================================================================
; dkv_parse
;
;=============================================================================
function dkv_parse, value

 ;---------------------------
 ; arrays delimited by ';'
 ;---------------------------
 value = str_nsplit(value, ';')
 if(n_elements(value) EQ 1) then value = value[0]

 return, value
end
;=============================================================================



;=============================================================================
; dkv_inputs
;
;=============================================================================
pro dkv_inputs, _dd, transient_keyvals, keyvals, ii, tr=tr, tf=tf, io=io


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; check translators
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 transient_keyvals = ''
 if(ptr_valid(_dd.tr_transient_keyvals_p)) then $
        		   transient_keyvals  = *_dd.tr_transient_keyvals_p

 keyvals = ''
 if(ptr_valid(_dd.tr_keyvals_p)) then keyvals = *_dd.tr_keyvals_p

 input_fns = *_dd.input_translators_p
 output_fns = *_dd.output_translators_p

 ii = dat_caller(input_fns)
 if(ii[0] NE -1) then return
 ii = dat_caller(output_fns)
 if(ii[0] NE -1) then return

 if(keyword_set(tr)) then return


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; check I/O methods
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 transient_keyvals = ''
 if(ptr_valid(_dd.io_transient_keyvals_p)) then $
        		   transient_keyvals  = *_dd.io_transient_keyvals_p

 keyvals = ''
 if(ptr_valid(_dd.io_keyvals_p)) then keyvals = *_dd.io_keyvals_p

 input_fns = _dd.input_fn
 output_fns = _dd.output_fn

 ii = dat_caller(input_fns)
 if(ii[0] NE -1) then return
 ii = dat_caller(output_fns)
 if(ii[0] NE -1) then return

 if(keyword_set(io)) then return


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; check transforms
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 transient_keyvals = ''
 if(ptr_valid(_dd.tf_transient_keyvals_p)) then $
        		   transient_keyvals  = *_dd.tf_transient_keyvals_p

 keyvals = ''
 if(ptr_valid(_dd.tf_keyvals_p)) then keyvals = *_dd.tf_keyvals_p

 input_fns = *_dd.input_transforms_p
 output_fns = *_dd.output_transforms_p

 ii = dat_caller(input_fns)
 if(ii[0] NE -1) then return
 ii = dat_caller(output_fns)
 if(ii[0] NE -1) then return

 if(keyword_set(tf)) then return


end
;=============================================================================



;=============================================================================
; dat_keyword_value
;
;=============================================================================
function dat_keyword_value, dd, keyword, tr=tr, tf=tf, io=io
@core.include

 _dd = cor_dereference(dd[0])

 ;----------------------------------------------------------------------
 ; get arrays
 ;----------------------------------------------------------------------
 dkv_inputs, _dd, transient_keyvals, keyvals, ii, tr=tr, tf=tf, io=io
 if(ii EQ -1) then return, ''


 ;----------------------------------------------------------------------
 ; first look for transient keyval match
 ;----------------------------------------------------------------------
 if(keyword_set(transient_keyvals)) then $
                dkv_match, transient_keyvals, 0, keyword, value=value
 if(n_elements(value) NE 0) then return, dkv_parse(value)


 ;-----------------
 ; match keyval 
 ;-----------------
 if(NOT keyword_set(keyvals)) then return, ''
 dkv_match, keyvals, ii, keyword, value=value
 if(NOT keyword_set(value)) then value = ''


 return, dkv_parse(value)
end
;=============================================================================
