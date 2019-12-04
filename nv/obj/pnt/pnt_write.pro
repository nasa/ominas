;=============================================================================
;+
; NAME:
; 	pnt_write
;
;
; PURPOSE:
; 	Writes a POINT object to a file.
;
;
; CATEGORY:
; 	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
; 	pnt_write, filename, ptd
;
;
; ARGUMENTS:
;  INPUT:
; 	filename:	Name of the file to write.
;
;	ptd:		POINT object to write.
;
;  OUTPUT: 
;	status: 	0 if successful; -1 otherwise.
;
;
; KEYWORDS:
;  INPUT:
; 	bin:	If set, a binary POINT object file is written;
; 		not currently implemented.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SEE ALSO:
;	pnt_read
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_write_ps
; 
;-
;=============================================================================
pro pnt_write, filename, ptd, bin=bin, noevent=noevent, status=status
 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)

 status = 0

 catch, err 
 if(keyword_set(err)) then $
  begin
   status = -1
   return
  end
 openw, unit, filename, /get_lun
 catch, /cancel

 nv_message, verb=0.1, 'Writing ' + filename

 printf, unit, 'protocol 4'
 if(keyword_set(bin)) then printf, unit, 'binary'

 nptd = n_elements(_ptd)
 printf, unit, 'nps = ' + strtrim(nptd,2)

 ;---------------------------------------------
 ; add each POINT object
 ;---------------------------------------------
 for i=0, nptd-1 do $
  begin
   ;- - - - - - - - - - - - - - - - -
   ; descriptive info
   ;- - - - - - - - - - - - - - - - -
   printf, unit
   printf, unit, 'name = ' + _ptd[i].name
   printf, unit, ' desc = ' + _ptd[i].desc

   n = pnt_nv(_ptd[i])
   printf, unit, ' n = ' + strtrim(n,2)

   ;- - - - - - - - - - - - - - - - -
   ; image points
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].points_p)) then $
    begin
     printf, unit, ' points:'

     points = *_ptd[i].points_p
     if(keyword_set(bin)) then writeu, unit, points $
     else $
      printf, unit, '  ' + strtrim(points[0,*],2) + ' ' + $
                           strtrim(points[1,*],2) 
    end

   ;- - - - - - - - - - - - - - - - -
   ; vectors
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].vectors_p)) then $
    begin
     printf, unit, ' vectors:' 

     vectors = *_ptd[i].vectors_p
     if(keyword_set(bin)) then writeu, unit, vectors $
     else $
      printf, unit, '  ' + tr( strtrim(vectors[*,0],2) + ' ' + $
                               strtrim(vectors[*,1],2) + ' ' + $
                               strtrim(vectors[*,2],2) )
    end

   ;- - - - - - - - - - - - - - - - -
   ; point data
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].data_p)) then $
    begin
     data = *_ptd[i].data_p
     s = size(data)
     ndim = s[0]

     if(ndim EQ 1) then data = tr(data)
     s = size(data)
     ndim = s[0]

     if(ndim GT 2) then $
             nv_message, 'Point data may have no more than 2 dimensions.'
     s = s[1:s[0]]
     w = where(s EQ n)
     if(w[0] EQ -1) then nv_message, 'Inconsistent point data.'
     nn = 1
     ww = where(s NE n)
     if(ww[0] NE -1) then nn = s[ww]

     printf, unit, ' point data:', nn

     if(keyword_set(bin)) then writeu, unit, data $
     else $
      begin
       data_s = strtrim(data,2)
       if(ndim NE 1) then  $
        begin
         if(w[0] EQ 0) then data_s = tr(data_s)
         bb = byte(data_s + ' ')
         sbb = size(bb)
         bbb = reform(bb, sbb[1]*sbb[2], sbb[3])
         ww = where(bbb EQ 0)
         if(ww[0] NE -1) then bbb[ww] = byte(' ')
         data_s = string(bbb)
        end

       printf, unit, '  ' + tr(data_s)
      end
    end

   ;- - - - - - - - - - - - - - - - -
   ; generic user data
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].udata_tlp)) then $
    begin
     printf, unit, ' udata:'
     tag_list_write, _ptd[i].udata_tlp, unit=unit, bin=bin
    end

   ;- - - - - - - - - - - - - - - - -
   ; point-by-point user data
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].tags_p)) then $
    begin
     printf, unit, ' tags:'
     printf, unit, '  ' + tr(strtrim(*_ptd[i].tags_p,2))
    end

   ;- - - - - - - - - - - - - - - - -
   ; flags
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].flags_p)) then $
    begin
     printf, unit, ' flags:'

     flags = fix(*_ptd[i].flags_p)
     if(keyword_set(bin)) then writeu, unit, flags $
     else printf, unit, '  ' + tr(strtrim(flags,2))
    end

   ;- - - - - - - - - - - - - - - - -
   ; notes
   ;- - - - - - - - - - - - - - - - -
   if(ptr_valid(_ptd[i].notes_p)) then $
    begin
     printf, unit, ' notes:'
     notes = *_ptd[i].notes_p
     if(keyword_set(notes)) then printf, unit, tr(notes)
     printf, unit, ' __end_notes__'
    end
  end

 close, unit
 free_lun, unit

end
;===========================================================================
