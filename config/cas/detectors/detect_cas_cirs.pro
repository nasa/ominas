;===========================================================================
; detect_cas_cirs.pro
;
;===========================================================================
function detect_cas_cirs, dd
 compile_opt idl2,logical_predicate
 label = (dat_header(dd));[0]
 if size(label,/type) ne 8 then return,''
 if ~total(strmatch(tag_names(label),'LABEL')) then return,''
 if total(stregex(label.label,'^INSTRUMENT_((NAME)|(ID))[[:blank:]]*=[[:blank:]]*"?((CIRS)|(COMPOSITE INFRARED SPECTROMETER))"?',/boolean,/fold_case)) then return, 'CAS_CIRS'

 return, ''
end
;===========================================================================

