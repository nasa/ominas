;===========================================================================
; data_archive_get
;
;  NOTE: a data value of scalar 0 is taken to be undefined.
;
;===========================================================================
function data_archive_get, dap, index, samples=_samples
 
 if(NOT ptr_valid(dap)) then return, 0
 if(NOT keyword_set(index)) then index = 0

 daps = *dap

; if(defined(_samples)) then $
;  if(n_elements(_samples) LE n_elements(*daps[index])) then samples = _samples

 if(defined(_samples)) then samples = _samples


 if(NOT defined(samples)) then return, *daps[index]

 return, (*daps[index])[samples]
end
;===========================================================================
