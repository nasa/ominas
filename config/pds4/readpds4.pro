;==============================================================================
; readpds4
;
;
;==============================================================================
function readpds4, filename, header, dat=dat

 ;--------------------------------------------------------
 ; read xml file
 ;--------------------------------------------------------
 dat = read_pds(filename)
 if(size(dat, /type) NE 8) then return, 0

 ;-----------------------------------------------------------------------
 ; The data array is the last field of the structure that is the last 
 ; field of the data structure returned by read_pds
 ;-----------------------------------------------------------------------
 s = dat.(n_tags(dat)-1)
 data = s.(n_tags(s)-1)


 ;------------------------------------------------------------------------
 ; Header structs have tag names HEADER<n>; we'll just take the frst one..
 ;------------------------------------------------------------------------
 tags = tag_names(dat)
 w = where(tags EQ 'HEADER1')
 if(w[0] NE -1) then hoff = (dat.(w[0])).header


 ;------------------------------------------------------------------------
 ; The header array gives offsets in the data file, so need to extract 
 ; actual header...
 ;------------------------------------------------------------------------
 if(keyword_set(hoff)) then $
  begin
   nlines = n_elements(hoff)
   header = strarr(nlines)
   
   fname = dat.data_file
   openr, unit, fname, /get_lun, error=error
   if(error NE 0) then nv_message, /anonymous, !err_string

   s = ''
   for i=0, nlines-2 do $
    begin
     readf, unit, s
     header[i] = s
    end

   close, unit
   free_lun, unit
  end

 return, data
end
;==============================================================================
