;=============================================================================
; gff_read
;
;=============================================================================
function gff_read, gff, subscripts=_subscripts


 dim = *gff.dim_p


;------------------------------------------
 ; open file 
 ;------------------------------------------
 openr, unit, gff.filename, /get_lun


 ;---------------------------------------------
 ; read entire array if no subscripts given
 ;---------------------------------------------
 if(NOT defined(_subscripts)) then $
  begin
   array = assoc(unit, make_array(dim, type=gff.type), gff.file_offset)
   data = array[0]
  end $
 else $
 ;---------------------------------------------
 ; otherwise read only subscripted data points
 ;---------------------------------------------
  begin
   subscripts = _subscripts
   n = n_elements(subscripts)

   data = make_array(n, type=gff.type)
   array = assoc(unit, [data[0]], gff.file_offset)

   data_offset = 0
   if(ptr_valid(gff.data_offset_p)) then data_offset = *gff.data_offset_p

   x = w_to_nd(dim, subscripts)
   xx = x + data_offset#make_array(n, val=1l)

   subscripts = nd_to_w(dim+data_offset, xx)

; could improve performance by detecting contiguous blocks of subscripts..
   for i=0, n-1 do data[i] = array[subscripts[i]]
  end


 ;------------------------------------------
 ; close file
 ;------------------------------------------
 close, unit
 free_lun, unit


 return, data
end
;=============================================================================
