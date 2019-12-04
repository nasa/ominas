;===========================================================================
; read_vicar_lite
;
;===========================================================================
read_vicar_lite, filename, label

 if(n_elements(n_l) NE 0) then nl=n_l
 if(n_elements(n_s) NE 0) then ns=n_s
 if(n_elements(n_b) NE 0) then nb=n_b

 if(NOT keyword_set(default_format)) then default_format='BYTE'


;----------------open file------------------

 openr, unit, filename, /get_lun, error=error
 if(error NE 0) then $
  begin
   status=!err_string
   if(NOT keyword_set(silent)) then message, status
   return, 0
  end


;---------------read label size----------------

 records=assoc(unit, bytarr(30, /nozero))
 record=records(0)
 str=string(record)

 label_nbytes=vicgetpar(str, 'LBLSIZE', status=status)
 if(keyword_set(status)) then $
  begin
   if(NOT keyword_set(silent)) then message, status
   close, unit
   free_lun, unit
   return, 0
  end

 dat = fstat(unit)
 label_nbytes = label_nbytes < dat.size


;-----------------get label-------------------

 label_records=assoc(unit, bytarr(label_nbytes, /nozero))
 label=string(label_records(0))




end
;===========================================================================
