;===========================================================================
; data_archive_set
;
;
;===========================================================================
pro data_archive_set, dap, data, nhist=nhist, index=index, noarchive=noarchive


 if(NOT defined(index)) then index = 0

 ;-------------------------------------------------
 ; construct new dap if not given
 ;-------------------------------------------------
 if(NOT keyword_set(dap)) then $
  begin
   if(NOT keyword_set(nhist)) then nhist = 2
   daps = ptrarr(nhist)
   for i=0, nhist-1 do daps[i] = nv_ptr_new(0)
   if(keyword_set(data)) then *daps[0] = data
   dap = nv_ptr_new(daps)
   return
  end


 ;------------------------------------------------
 ; modify nhist if given
 ;------------------------------------------------ 
 if(keyword_set(nhist)) then $
  begin
   daps = *dap
   _nhist = n_elements(daps)
   if(nhist NE _nhist) then $
    begin
     if(nhist LT _nhist) then $
      begin
       ptr_free, daps[nhist:*]
       daps = daps[0:nhist-1]
      end $
     else $
      begin
       nnew = nhist-_nhist
       new = ptrarr(nnew)
       for i=0, nnew-1 do new[i] = nv_ptr_new(0)	; can't use nv_ in util/ routines
       daps = [daps, new]
      end
     *dap = daps
    end
  end

 if(NOT keyword_set(data)) then return


 ;----------------------------------------------------------------------
 ; insert data as indicated
 ;----------------------------------------------------------------------
 daps = *dap
 nhist = n_elements(daps)
 jj = 0

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if archiving disabled:
 ;  - replace data in indexed position
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(noarchive)) then $
  begin
   ii = lindgen(nhist)
   jj = index
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; if inserting data at nonzero position:
 ;  - delete all data at smaller indices
 ;  - shift everything such that new data is at zero position
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 else if(keyword_set(index)) then $
  begin
   ii = lindgen(nhist) + index - 1
   w = where(ii GE nhist)
   if(w[0] NE -1) then $
    begin
     ii[w] = ii[w] - nhist
     nw = n_elements(w)
     for i=0, nw-1 do  *daps[ii[w[i]]] = 0
    end
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; otherwise, shift everything back and insert new data at front
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   ii = lindgen(nhist) - 1
   ii[0] = nhist-1
  end

 daps = daps[ii]
 *daps[jj] = data
 *dap = daps
end
;===========================================================================
