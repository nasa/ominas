;===========================================================================
; data_archive_defined
;
;  NOTE: a data value of scalar 0 is taken to be undefined.
;
;===========================================================================
function data_archive_defined, dap, index

 if(NOT ptr_valid(dap)) then return, 0
 if(NOT keyword_set(index)) then index = 0

 daps = *dap

 return, keyword_set(*daps[index])
end
;===========================================================================
