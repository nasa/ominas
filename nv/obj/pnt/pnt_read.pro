;=============================================================================
;+
; NAME:
; 	pnt_read
;
;
; PURPOSE:
; 	Reads a POINT file.
;
;
; CATEGORY:
; 	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
; 	ptd = pnt_read(filename)
;
;
; ARGUMENTS:
;  INPUT:
; 	filename: Name of the file to read.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
; 	bin:		If set, a binary POINT file is read;
; 			not currently implemented.
;
; 	visible:	If set, only visible points are returned.
;
; 	no_ptd:		If set, POINT objects are not created.
;
;  OUTPUT:
; 	name: 		Array names.
;
; 	desc:  		Array descriptions.
;
; 	flags:  	Array flags
;
; 	points:  	Point arrays.
;
; 	vectors: 	Vector arrays.
;
;	comment:	Returns all lines starting with '#', which are 
;			not otherwise parsed. 
;
;	notes:		Array notes.
;
;
; RETURN:
; 	Normally, this routine returns a POINT containing
; 	the points from the file.  If no_ptd is set, then 0 is returned 
; 	instead.
;
;
; SEE ALSO:
;	pnt_write
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_read_ps
; 
;-
;=============================================================================



;=============================================================================
; pnt_read_0
;
;=============================================================================
function pnt_read_0, filename, visible=visible, $
         name=name, desc=desc, flags=_flags, points=points, vectors=vectors, $
         comment=comment

 lines = read_txt_file(filename, /raw)

 ;- - - - - - - - - - - - - - - - - - -
 ; get array names
 ;- - - - - - - - - - - - - - - - - - -
 w = where(strmid(lines, 0, 5)  EQ 'NAME:')
 if(w[0] NE -1) then name = lines[w+1]

 if(keyword_set(name)) then $
  begin
   nptd = n_elements(name)

   ;- - - - - - - - - - - - - - - - - - -
   ; get comments
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines,0,1) EQ '#')
   if(w[0] NE -1) then $ 
    begin
     comment = lines[w]
     nv_message, verb=0.9, filename + ':'
     nv_message, verb=0.9, tr(comment)
    end

   ;- - - - - - - - - - - - - - - - - - -
   ; get array descriptions
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 5)  EQ 'DESC:')
   if(w[0] NE -1) then desc = lines[w+1]

   ;- - - - - - - - - - - - - - - - - - -
   ; get point flags
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 6)  EQ 'FLAGS:')
   if(w[0] NE -1) then $
    begin
     flags = bytarr(nptd)
     for i=0, nptd-1 do flags[i] = byte(lines[w[i]+1])
    end

   ;- - - - - - - - - - - - - - - - - - -
   ; get points
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 7)  EQ 'POINTS:')
   if(w[0] NE -1) then $
    begin
     ww = [w+1, w+2]
     ss = sort(ww)
     ww = ww[ss]
     points = reform(double(lines[ww]), 2, nptd, /over)
    end

   ;- - - - - - - - - - - - - - - - - - -
   ; get vectors
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 8)  EQ 'VECTORS:')
   if(w[0] NE -1) then $
    begin
     ww = [w+1, w+2, w+3]
     vectors = reform(double(lines[ww]), nptd, 3, /over)
    end

  end


 ;- - - - - - - - - - - - - - - - - - - - -
 ; construct POINT objects
 ;- - - - - - - - - - - - - - - - - - - - -
 for i=0, nptd-1 do $
  begin
   if(keyword__set(flags)) then _flags = flags[i]
   if(keyword__set(desc)) then _desc = desc[i]
   if(keyword__set(points)) then _points = points[*,i]
   if(keyword__set(vectors)) then _vectors = vectors[i,*]
   ptd = append_array(ptd, pnt_create_descriptors(name=name[i], desc=_desc, flags=_flags, $
              points=_points, vectors=_vectors))
  end


 return, ptd
end
;===========================================================================



;=============================================================================
; psrpnt_get_next
;
;=============================================================================
function psrpnt_get_next, unit, token, stop=stop, status=status, n=n, $
                           bin=bin, buf=buf

 if(NOT keyword_set(n)) then n = 1
 status = 0

 if(keyword_set(bin)) then $
  begin
   readu, unit, buf
   return, buf
  end

 line = make_array(n, val='')
 done = 0
 while not eof(unit) do $
  begin
   fs = fstat(unit)
   save_ptr = fs.cur_ptr
   readf, unit, line
   if(NOT keyword_set(token)) then done = 1 $
   else $
    begin
     p = strpos(line, token) 
     if(p[0] NE -1) then done = 1
     if(keyword_set(stop) AND (NOT done)) then $
      begin
       p = strpos(line, stop) 
       if(p[0] NE -1) then $
        begin
         done = 1
         status = -1
         point_lun, unit, save_ptr
        end
      end
    end

   if(done) then return, strtrim(line,2)
  end

 status = -1
 return, ''
end
;=============================================================================



;=============================================================================
; pnt_read_1
;
;=============================================================================
function pnt_read_1, filename, visible=visible, $
         name=name, desc=desc, flags=f, points=p, vectors=v, $
         comment=comment, version=version, data=data, tags=tags

 
 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 name_token = 'name ='

 line = psrpnt_get_next(unit)

 bin = 0
 fs = fstat(unit)
 save_ptr = fs.cur_ptr
 line = psrpnt_get_next(unit)
 p = strpos(line, 'binary')
 if(p[0] NE -1) then bin = 1 $
 else point_lun, unit, save_ptr


 done = 0
 repeat $
  begin
   ;- - - - - - - - - - - - - - - - - - -
   ; name, desc, n
   ;- - - - - - - - - - - - - - - - - - -
   line = psrpnt_get_next(unit, name_token, stat=stat)
   if(stat EQ -1) then done = 1 $
   else $
    begin
     name = strtrim(strep_s(line, name_token, ''), 2)
     desc = strtrim(strep_s(psrpnt_get_next(unit), 'desc =', ''), 2)
     if(version GT 0) then input = strtrim(strep_s(psrpnt_get_next(unit), 'input =', ''), 2)
;stop
     n = fix(strtrim((str_sep(psrpnt_get_next(unit), ' '))[2], 2))

     ;- - - - - - - - - - - - - - - - - - -
     ; points
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'points:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(2,n))
       if(bin) then p = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=ys)
         p = [tr(double(xs)), tr(double(ys))]
        end
      end

     ;- - - - - - - - - - - - - - - - - - -
     ; vectors
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'vectors:', stop=':', stat=stat)
     v = 0
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(3,n))
       if(bin) then v = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=rem)
         ys = str_nnsplit(rem, ' ', rem=zs)
         v = tr([tr(double(xs)), tr(double(ys)), tr(double(zs))])
        end
      end
 
     ;- - - - - - - - - - - - - - - - -
     ; point data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'point data:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       ss = str_nsplit(strcompress(line[0]), ' ')

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; This is a crap protocol.  Shouldn't exist, but somehow does.
       ;  It looks like a protocol 1 file, but the point data are stored
       ;  like a protocol 0 file.
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(n_elements(ss) EQ 2) then $
        begin
         done = 0
         repeat $
          begin
           readf, unit, line
           pp = strpos(line, ':')
           if(pp[0] EQ -1) then data = append_array(data, double(line)) $
           else done = 1
          endrep until(done)

         data = reform(data)
        end $
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; this is the real protocol...
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       else $
        begin
         nn = fix(ss[n_elements(ss)-1])

         buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(nn,n))
         if(bin) then data = buf $
         else $
          begin
           lines = strcompress(buf)
           test = str_nsplit(lines[0], ' ')
           nn = n_elements(test)
           data = dblarr(n, nn)

           rem = lines

;           for i=0, nn-1 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           for i=0, nn-2 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           data[*,i] = rem
          end

         if(n GT 1) then data = reform(data) 
        end

       data = transpose(data)
      end     


     ;- - - - - - - - - - - - - - - - -
     ; generic user data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'udata:', stop=':', stat=stat)
     if(stat EQ 0) then udata_tlp = tag_list_read(unit=unit, bin=bin)


     ;- - - - - - - - - - - - - - - - - - -
     ; tags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'tags:', stop=':', stat=stat)
     if(stat EQ 0) then $
          tags = psrpnt_get_next(unit, n=nn, buf=bytarr(nn))


     ;- - - - - - - - - - - - - - - - - - -
     ; flags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'flags:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=bytarr(n))
       if(bin) then f = buf $
       else f = byte(fix(buf))
      end
   

     ;- - - - - - - - - - - - - - - - - - -
     ; make ptd
     ;- - - - - - - - - - - - - - - - - - -
     ptd = append_array(ptd, $
             pnt_create_descriptors(name=name, desc=desc, flags=f, $
                points=p, vectors=v, data=data, tag=tags, udata=udata_tlp) )
    end
  endrep until(done)


 close, unit
 free_lun, unit

 return, ptd
end
;===========================================================================



;=============================================================================
; pnt_read_2
;
;=============================================================================
function pnt_read_2, filename, visible=visible, $
         name=name, desc=desc, flags=f, points=p, vectors=v, $
         comment=comment, version=version, data=data, tags=tags

 
 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 name_token = 'name ='

 line = psrpnt_get_next(unit)

 bin = 0
 fs = fstat(unit)
 save_ptr = fs.cur_ptr
 line = psrpnt_get_next(unit)
 p = strpos(line, 'binary')
 if(p[0] NE -1) then bin = 1 $
 else point_lun, unit, save_ptr


 done = 0
 repeat $
  begin
   ;- - - - - - - - - - - - - - - - - - -
   ; name, desc, n
   ;- - - - - - - - - - - - - - - - - - -
   line = psrpnt_get_next(unit, name_token, stat=stat)
   if(stat EQ -1) then done = 1 $
   else $
    begin
     name = strtrim(strep_s(line, name_token, ''), 2)
     desc = strtrim(strep_s(psrpnt_get_next(unit), 'desc =', ''), 2)
     n = fix(strtrim((str_sep(psrpnt_get_next(unit), ' '))[2], 2))

     ;- - - - - - - - - - - - - - - - - - -
     ; points
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'points:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(2,n))
       if(bin) then p = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=ys)
         p = [tr(double(xs)), tr(double(ys))]
        end
      end

     ;- - - - - - - - - - - - - - - - - - -
     ; vectors
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'vectors:', stop=':', stat=stat)
     v = 0
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(3,n))
       if(bin) then v = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=rem)
         ys = str_nnsplit(rem, ' ', rem=zs)
         v = tr([tr(double(xs)), tr(double(ys)), tr(double(zs))])
        end
      end
 
     ;- - - - - - - - - - - - - - - - -
     ; point data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'point data:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       ss = str_nsplit(strcompress(line[0]), ' ')

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; This is a crap protocol.  Shouldn't exist, but somehow does.
       ;  It looks like a protocol 1 file, but the point data are stored
       ;  like a protocol 0 file.
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(n_elements(ss) EQ 2) then $
        begin
         done = 0
         repeat $
          begin
           readf, unit, line
           pp = strpos(line, ':')
           if(pp[0] EQ -1) then data = append_array(data, double(line)) $
           else done = 1
          endrep until(done)

         data = reform(data)
        end $
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; this is the real protocol...
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       else $
        begin
         nn = fix(ss[n_elements(ss)-1])

         buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(nn,n))
         if(bin) then data = buf $
         else $
          begin
           lines = strcompress(buf)
           test = str_nsplit(lines[0], ' ')
           nn = n_elements(test)
           data = dblarr(n, nn)

           rem = lines

;           for i=0, nn-1 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           for i=0, nn-2 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           data[*,i] = rem
          end

         if(n GT 1) then data = reform(data) 
        end

       data = transpose(data)
      end     


     ;- - - - - - - - - - - - - - - - -
     ; generic user data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'udata:', stop=':', stat=stat)
     if(stat EQ 0) then udata_tlp = tag_list_read(unit=unit, bin=bin)


     ;- - - - - - - - - - - - - - - - - - -
     ; tags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'tags:', stop=':', stat=stat)
     if(stat EQ 0) then $
          tags = psrpnt_get_next(unit, n=nn, buf=bytarr(nn))


     ;- - - - - - - - - - - - - - - - - - -
     ; flags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'flags:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=bytarr(n))
       if(bin) then f = buf $
       else f = byte(fix(buf))
      end
   

     ;- - - - - - - - - - - - - - - - - - -
     ; make ptd
     ;- - - - - - - - - - - - - - - - - - -
     ptd = append_array(ptd, $
             pnt_create_descriptors(name=name, desc=desc, flags=f, $
                points=p, vectors=v, data=data, tag=tags, udata=udata_tlp) )
    end
  endrep until(done)


 close, unit
 free_lun, unit

 return, ptd
end
;===========================================================================



;=============================================================================
; pnt_read_3
;
;=============================================================================
function pnt_read_3, filename, visible=visible, $
         name=name, desc=desc, flags=f, points=p, vectors=v, $
         comment=comment, version=version, data=data, tags=tags, notes=notes

 
 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 name_token = 'name ='

 line = psrpnt_get_next(unit)

 bin = 0
 fs = fstat(unit)
 save_ptr = fs.cur_ptr
 line = psrpnt_get_next(unit)
 p = strpos(line, 'binary')
 if(p[0] NE -1) then bin = 1 $
 else point_lun, unit, save_ptr


 done = 0
 repeat $
  begin
   ;- - - - - - - - - - - - - - - - - - -
   ; name, desc, n
   ;- - - - - - - - - - - - - - - - - - -
   line = psrpnt_get_next(unit, name_token, stat=stat)
   if(stat EQ -1) then done = 1 $
   else $
    begin
     name = strtrim(strep_s(line, name_token, ''), 2)
     desc = strtrim(strep_s(psrpnt_get_next(unit), 'desc =', ''), 2)
     n = fix(strtrim((str_sep(psrpnt_get_next(unit), ' '))[2], 2))

     ;- - - - - - - - - - - - - - - - - - -
     ; points
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'points:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(2,n))
       if(bin) then p = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=ys)
         p = [tr(double(xs)), tr(double(ys))]
        end
      end

     ;- - - - - - - - - - - - - - - - - - -
     ; vectors
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'vectors:', stop=':', stat=stat)
     v = 0
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(3,n))
       if(bin) then v = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=rem)
         ys = str_nnsplit(rem, ' ', rem=zs)
         v = tr([tr(double(xs)), tr(double(ys)), tr(double(zs))])
        end
      end
 
     ;- - - - - - - - - - - - - - - - -
     ; point data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'point data:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       ss = str_nsplit(strcompress(line[0]), ' ')

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; This is a crap protocol.  Shouldn't exist, but somehow does.
       ;  It looks like a protocol 1 file, but the point data are stored
       ;  like a protocol 0 file.
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(n_elements(ss) EQ 2) then $
        begin
         done = 0
         repeat $
          begin
           readf, unit, line
           pp = strpos(line, ':')
           if(pp[0] EQ -1) then data = append_array(data, double(line)) $
           else done = 1
          endrep until(done)

         data = reform(data)
        end $
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; this is the real protocol...
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       else $
        begin
         nn = fix(ss[n_elements(ss)-1])

         buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(nn,n))
         if(bin) then data = buf $
         else $
          begin
           lines = strcompress(buf)
           test = str_nsplit(lines[0], ' ')
           nn = n_elements(test)
           data = dblarr(n, nn)

           rem = lines

;           for i=0, nn-1 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           for i=0, nn-2 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           data[*,i] = rem
          end

         if(n GT 1) then data = reform(data) 
        end

       data = transpose(data)
      end     


     ;- - - - - - - - - - - - - - - - -
     ; generic user data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'udata:', stop=':', stat=stat)
     if(stat EQ 0) then udata_tlp = tag_list_read(unit=unit, bin=bin)


     ;- - - - - - - - - - - - - - - - - - -
     ; tags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'tags:', stop=':', stat=stat)
     if(stat EQ 0) then $
          tags = psrpnt_get_next(unit, n=nn, buf=bytarr(nn))


     ;- - - - - - - - - - - - - - - - - - -
     ; flags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'flags:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=bytarr(n))
       if(bin) then f = buf $
       else f = byte(fix(buf))
      end
   
     ;- - - - - - - - - - - - - - - - - - -
     ; notes -- read to eof
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'notes:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       notes = ''
       while(NOT eof(unit)) do $
	begin
	 readf, unit, line
	 notes = append_array(notes, line)
	end
      end


     ;- - - - - - - - - - - - - - - - - - -
     ; make ptd
     ;- - - - - - - - - - - - - - - - - - -
     ptd = append_array(ptd, $
             pnt_create_descriptors(name=name, desc=desc, flags=f, $
                points=p, vectors=v, data=data, tag=tags, udata=udata_tlp, notes=notes) )
    end
  endrep until(done)


 close, unit
 free_lun, unit

 return, ptd
end
;===========================================================================



;=============================================================================
; pnt_read_4
;
;=============================================================================
function pnt_read_4, filename, visible=visible, $
         name=name, desc=desc, flags=f, points=p, vectors=v, $
         comment=comment, version=version, data=data, tags=tags, notes=notes

 
 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 name_token = 'name ='

 line = psrpnt_get_next(unit)

 bin = 0
 fs = fstat(unit)
 save_ptr = fs.cur_ptr
 line = psrpnt_get_next(unit)
 p = strpos(line, 'binary')
 if(p[0] NE -1) then bin = 1 $
 else point_lun, unit, save_ptr


 done = 0
 repeat $
  begin
   ;- - - - - - - - - - - - - - - - - - -
   ; name, desc, n
   ;- - - - - - - - - - - - - - - - - - -
   line = psrpnt_get_next(unit, name_token, stat=stat)
   if(stat EQ -1) then done = 1 $
   else $
    begin
     name = strtrim(strep_s(line, name_token, ''), 2)
     desc = strtrim(strep_s(psrpnt_get_next(unit), 'desc =', ''), 2)
     n = fix(strtrim((str_sep(psrpnt_get_next(unit), ' '))[2], 2))

     ;- - - - - - - - - - - - - - - - - - -
     ; points
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'points:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(2,n))
       if(bin) then p = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=ys)
         p = [tr(double(xs)), tr(double(ys))]
        end
      end

     ;- - - - - - - - - - - - - - - - - - -
     ; vectors
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'vectors:', stop=':', stat=stat)
     v = 0
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(3,n))
       if(bin) then v = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=rem)
         ys = str_nnsplit(rem, ' ', rem=zs)
         v = tr([tr(double(xs)), tr(double(ys)), tr(double(zs))])
        end
      end
 
     ;- - - - - - - - - - - - - - - - -
     ; point data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'point data:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       ss = str_nsplit(strcompress(line[0]), ' ')

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; This is a crap protocol.  Shouldn't exist, but somehow does.
       ;  It looks like a protocol 1 file, but the point data are stored
       ;  like a protocol 0 file.
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(n_elements(ss) EQ 2) then $
        begin
         done = 0
         repeat $
          begin
           readf, unit, line
           pp = strpos(line, ':')
           if(pp[0] EQ -1) then data = append_array(data, double(line)) $
           else done = 1
          endrep until(done)

         data = reform(data)
        end $
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; this is the real protocol...
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       else $
        begin
         nn = fix(ss[n_elements(ss)-1])

         buf = psrpnt_get_next(unit, n=n, bin=bin, buf=dblarr(nn,n))
         if(bin) then data = buf $
         else $
          begin
           lines = strcompress(buf)
           test = str_nsplit(lines[0], ' ')
           nn = n_elements(test)
           data = dblarr(n, nn)

           rem = lines

;           for i=0, nn-1 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           for i=0, nn-2 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           data[*,i] = rem
          end

         if(n GT 1) then data = reform(data) 
        end

       data = transpose(data)
      end     


     ;- - - - - - - - - - - - - - - - -
     ; generic user data
     ;- - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'udata:', stop=':', stat=stat)
     if(stat EQ 0) then udata_tlp = tag_list_read(unit=unit, bin=bin)


     ;- - - - - - - - - - - - - - - - - - -
     ; tags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'tags:', stop=':', stat=stat)
     if(stat EQ 0) then $
          tags = psrpnt_get_next(unit, n=nn, buf=bytarr(nn))


     ;- - - - - - - - - - - - - - - - - - -
     ; flags
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'flags:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = psrpnt_get_next(unit, n=n, bin=bin, buf=bytarr(n))
       if(bin) then f = buf $
       else f = byte(fix(buf))
      end
   
     ;- - - - - - - - - - - - - - - - - - -
     ; notes -- read to eof
     ;- - - - - - - - - - - - - - - - - - -
     line = psrpnt_get_next(unit, 'notes:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       notes = ''
       while(NOT eof(unit)) do $
	begin
	 readf, unit, line
         if(strtrim(line,2) EQ '__end_notes__') then break
	 notes = append_array(notes, line)
	end
      end


     ;- - - - - - - - - - - - - - - - - - -
     ; make ptd
     ;- - - - - - - - - - - - - - - - - - -
     ptd = append_array(ptd, $
             pnt_create_descriptors(name=name, desc=desc, flags=f, $
                points=p, vectors=v, data=data, tag=tags, udata=udata_tlp, notes=notes) )
    end
  endrep until(done)


 close, unit
 free_lun, unit

 return, ptd
end
;===========================================================================



;=============================================================================
; pnt_read
;
;=============================================================================
function pnt_read, filename, bin=bin, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, data=data, tags=tags, notes=notes
@pnt_include.pro

 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 line = ''
 readf, unit, line
 close, unit
 free_lun, unit


 ;---------------------------------------------------------------------
 ; Check protocol on line 0.  If none specified, then it's protocol 0
 ;---------------------------------------------------------------------
 protocol = 0
 s = str_sep(line, ' ')
 if(keyword_set(s[0])) then $
  begin
   if(s[0] NE 'protocol') then nv_message, 'Syntax error in file ' + filename+ '.'
   w = str_isalpha(s[1])
   if(w[0] NE -1) then nv_message, 'Syntax error in file ' + filename+ '.'
   protocol = fix(s[1])
   version = fix((float(s[1]) - protocol) * 10)
  end


 ;---------------------------------------------------------------------
 ; parse file according to protocol
 ;---------------------------------------------------------------------
 nv_message, verb=0.1, 'Reading ' + filename
 case protocol of
  0: begin
      ptd = pnt_read_0(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment)
     end
  1: ptd = pnt_read_1(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, version=version, data=data, tags=tags)
  2: ptd = pnt_read_2(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, version=version, data=data, tags=tags)
  3: ptd = pnt_read_3(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, version=version, data=data, tags=tags, notes=notes)
  4: ptd = pnt_read_4(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, version=version, data=data, tags=tags, notes=notes)
  else: nv_message, 'Invalid protocol.'
 endcase




 return, ptd
end
;=============================================================================





