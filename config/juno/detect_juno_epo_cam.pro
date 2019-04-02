;===========================================================================
; detect_juno_epo_cam.pro
;
;===========================================================================
function detect_juno_epo_cam, filename=filename, header=header, dd

if isa(label,'hash') && label.haskey('INSTRUMENT_NAME') $
  then return,idl_validname(label['INSTRUMENT_NAME'],/convert_all)


 return, ''
end
;===========================================================================
