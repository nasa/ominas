;===========================================================================
; detect_cas_iss.pro
;
;===========================================================================
function detect_cas_iss, dd

 label = (dat_header(dd))[0]
 if(NOT keyword_set(label)) then return, ''


 ; w10n json labels...
 if ~isa(label,'string') then return,0
 if ((strpos(label, '"ISSNA"') NE -1) AND $
         (strpos(label, 'CASSINI') NE -1)) then return, 'CAS_ISS_NA'
 if ((strpos(label, '"ISSWA"') NE -1) AND $
         (strpos(label, 'CASSINI') NE -1)) then return, 'CAS_ISS_WA'

 ; vicar labels...
 if( (strpos(label, 'CAS-ISS1') NE -1) $
      OR ((strpos(label, "'ISSNA'") NE -1) AND $
          (strpos(label, 'CASSINI') NE -1)) ) then return, 'CAS_ISS_NA'
 if( (strpos(label, 'CAS-ISS2') NE -1) $
      OR ((strpos(label, "'ISSWA'") NE -1) AND $
          (strpos(label, 'CASSINI') NE -1)) ) then return, 'CAS_ISS_WA'

 return, ''
end
;===========================================================================



;===========================================================================
; detect_cas_iss.pro
;
;===========================================================================
function ___detect_cas_iss, dd

 label = (dat_header(dd))[0]


 ; w10n json
 filetype = dat_filetype(dd)
 if (filetype EQ 'W10N_PDS') then begin
    if ((strpos(label, '"ISSNA"') NE -1) AND $
         (strpos(label, 'CASSINI') NE -1)) then return, 'CAS_ISS_NA'
    if ((strpos(label, '"ISSWA"') NE -1) AND $
         (strpos(label, 'CASSINI') NE -1)) then return, 'CAS_ISS_WA'
 endif

 if( (strpos(label, 'CAS-ISS1') NE -1) $
      OR ((strpos(label, "'ISSNA'") NE -1) AND $
          (strpos(label, 'CASSINI') NE -1)) ) then return, 'CAS_ISS_NA'
 if( (strpos(label, 'CAS-ISS2') NE -1) $
      OR ((strpos(label, "'ISSWA'") NE -1) AND $
          (strpos(label, 'CASSINI') NE -1)) ) then return, 'CAS_ISS_WA'

 return, ''
end
;===========================================================================
