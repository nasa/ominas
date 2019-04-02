;=============================================================================
;+
; NAME:
;	read_txt_file
;
;
; PURPOSE:
;	Reads a text file, parsing some basic directives and removing
;	comments.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	text = read_txt_file(fname, notes)
;
;
; ARGUMENTS:
;  INPUT:
;	fname:	Name of the file to read.
;
;  OUTPUT: 
;	notes:  Array of strings giving note text for each line.  This text is taken
;		from the 'note' input.
;
;
; KEYWORDS:
;  INPUT: 
;	start:	If given, the returned text begins at the first line
;		in which this string appears.  Default is '--begin--'.
;
;	stop:	If given, the returned text ends at the first line
;		in which this string appears.  Default is '--end--'.
;
;       note:	If this string appears in the file, this line is used as the note 
;		for each returned line until this string appears again, and so on.
;		Default is '--note--'.
;
;	raw:	If set, the 'start' and 'stop' keywords are ignored.
;		Comments are also not removed.
;
;	all:	If set, the 'start' and 'stop' keywords are ignored.
;
;	sample:	If set, only every nth line is returned, where n is the value
;		of this keyword; the first line is always returned.  If there 
;		are notes, then this operation applies separately to each block 
;		of lines with the same note.
;
;	select: If set, only lines with the given note string will be returned.
;		
;
;  OUTPUT:
;	status:	0 if successful, -1 if file not found
;
;
; RETURN:
;	String array containing the text read from the file.  Unless /raw
;	is specified, the returned text will not contain any characters
;	appearing after the comment character '#', and the start and stop
;	directoves are used to select the return block of text.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	write_txt_file
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/1994
;	
;-
;=============================================================================



;=============================================================================
; rtf_read
;
;
;=============================================================================
function rtf_read, fname, notes, status=status, note=note, lf=lf, $
          start=start, stop=stop, raw=raw, include=include, all=all, $
          sample=sample, offset=offset, select=select, unotes=unotes, $
          indices=indices, flags=flags, fnotes=fnotes

 if(NOT keyword_set(start)) then start = '--begin--'
 if(NOT keyword_set(stop)) then stop = '--end--'
 if(NOT keyword_set(note)) then note = '--note--'
 
 ;----------------------------------------
 ; make sure file exists
 ;----------------------------------------
 status = 0

 check = file_test(fname)

 if(NOT check) then $
  begin
   status = -1
   return, ['']
  end

 ;----------------------------------------
 ; read file
 ;----------------------------------------
 openr, unit, fname, /get_lun

 ff = fstat(unit)
 buf = assoc(unit, bytarr(ff.size, /nozero))
 bb = buf[0]

 w = where(bb EQ 10)
 if(keyword_set(lf)) then w = where(bb EQ 13)

 nlines = n_elements(w)
 text = strarr(nlines)
 w = [-1,w]

 i = -1l
 while (i LT nlines-1) do $
  begin
   i = i + 1
   a = w[i]+1 & b = w[i+1]-1
   if(a LE b) then text[i] = string(bb[a:b])
  end

 close, unit
 free_lun, unit


 ;----------------------------------------
 ; parse
 ;----------------------------------------
 if(NOT keyword_set(raw)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - -
   ; parse "--begin--" and "--end--"
   ;- - - - - - - - - - - - - - - - - - - - - - -
   if(NOT keyword_set(all)) then $
    begin
     n = n_elements(text)
     p = strpos(text, start) & w = where(p NE -1)
     pp = strpos(text, stop) & ww = where(pp NE -1)
     if(w[0] EQ -1) then w = [0]
     if(ww[0] EQ -1) then ww = [n-1]

     if(ww[0] LT w[0]) then w = [0, w]
     nw = n_elements(w) & nww = n_elements(ww)
     if(w[nw-1] GT ww[nww-1]) then ww = [ww, n-1]
     nw = n_elements(w) & nww = n_elements(ww)

     if(nw NE nww) then nv_message, 'Parse error in file: ' + fname

     for i=0, nw-1 do _text = append_array(_text, text[w[i]:ww[i]])
     text = _text
    end


   ;- - - - - - - - - - - - - - - - - - - - - - -
   ; parse "@"; note the recursion
   ;- - - - - - - - - - - - - - - - - - - - - - -
   split_filename, fname, dir, name
   include = ''
   repeat $
    begin
     p = strpos(text, '@')
     w = min(where(p EQ 0))
     if(w[0] NE -1) then $
      begin
       w = w[0]
       insert_fname = strmid(text[w], 1, strlen(text[w]))
       split_filename, insert_fname, insert_dir, insert_name
       if(NOT keyword_set(insert_dir)) then insert_fname = dir + path_sep() + insert_fname

       include = append_array(include, insert_fname)
       insert_text = read_txt_file(insert_fname, $
                                        start=start, stop=stop, raw=raw, all=all)
       pre = ''
       if(w GT 1) then pre = text[0:w-1]
       post = ''
       if(w LT n_elements(text)-1) then post = text[w+1:*]

       text = [pre, insert_text, post]
      end
    endrep until(w[0] EQ -1)


   ;- - - - - - - - - - - - - - - - - - - - - - -
   ; parse "--note--"
   ;- - - - - - - - - - - - - - - - - - - - - - -
   notes = strarr(n_elements(text))
   p = strpos(text, note) & w = where(p NE -1)
   if(w[0] NE -1) then $
    begin
     nw = n_elements(w)
     w = [w, n_elements(text)-1]
     for i=0, nw-1 do $
      begin
       _note = strmid(text[w[i]], p[w[i]]+strlen(note), strlen(text[w[i]])-strlen(note))
       _note = strtrim(_note,2)
       notes[w[i]:w[i+1]] = _note
       unotes = append_array(unotes, _note)
      end
    end
  end


 n = n_elements(text)
 if(NOT keyword_set(notes)) then notes = strarr(n)


 ;--------------------------------------
 ; apply selections
 ;--------------------------------------
 if(keyword_set(select)) then $
  begin
   w = nnwhere(notes, select)
   if(w[0] EQ -1) then text = '' $
   else $
    begin
     text = text[w]
     notes = notes[w]
    end
  end


 ;--------------------------------------
 ; remove comments
 ;--------------------------------------
 if(NOT keyword_set(raw)) then $
  begin
   text = strip_comment(text, w=w)
   if(keyword_set(notes)) then $
    begin
     if(w[0] EQ -1) then notes = '' $
     else notes = notes[w]
    end
  end
 n = n_elements(text)


 ;--------------------------------------
 ; apply sampling
 ;--------------------------------------
 if(keyword_set(sample)) then $
  begin
   ii = lindgen(n)

   if(NOT keyword_set(offset)) then offset = 0

   nu = n_elements(unotes)
   if(nu EQ 0) then iii = skip(ii, sample) $ 
   else for i=0, nu-1 do $
    begin
     w = where(notes EQ unotes[i])
     w = skip(w, sample)
     if(w[0] NE -1) then iii = append_array(iii, ii[w], /def)
    end

   iii = iii + offset

   text = text[iii]
   notes = notes[iii]
  end
 n = n_elements(text)


 ;--------------------------------------
 ; parse flags
 ;--------------------------------------
  if(NOT keyword_set(raw)) then $
  begin
   done = 0
   flags = bytarr(n_elements(text))
   while(NOT done) do $
    begin
     w = where(strmid(text, 0, 1) EQ '*')
     if(w[0] EQ -1) then done = 1 $
     else $
      begin
       flags[w] = flags[w] + 1
       text[w] = strmid(text[w], 1, 1000)
      end
    end
  end


 ;--------------------------------------
 ; parse fnotes
 ;--------------------------------------
 if(NOT keyword_set(raw)) then $
  begin
   fnotes = strarr(n_elements(text))
   p = strpos(text, '|')
   w = where(p NE -1)
   if(w[0] NE -1) then $
    begin
     ss = str_nnsplit(text, '|', rem=s)
     text[w] = ss[w]
     fnotes[w] = s[w]
    end
  end


 ;--------------------------------------
 ; apply indices
 ;--------------------------------------
 if(defined(indices)) then text = text[indices]

;print, fname
;stop

 return, text
end
;==========================================================================



;=============================================================================
; read_txt_file
;
;
;=============================================================================
function read_txt_file, fname, notes, status=status, note=note, lf=lf, $
          start=start, stop=stop, raw=raw, include=include, all=all, $
          sample=sample, offset=offset, select=select, unotes=unotes, indices=indices, $
          flags=flags, fnotes=fnotes


;return, rtf_read(fname, notes, status=status, note=note, lf=lf, $
;          start=start, stop=stop, raw=raw, include=include, all=all, $
;          sample=sample, offset=offset, select=select, unotes=unotes, indices=indices, $
;          flags=flags, fnotes=fnotes


 for i=0, n_elements(fname)-1 do $
  begin
   _text = rtf_read(fname[i], notes, status=status, note=note, lf=lf, $
          start=start, stop=stop, raw=raw, include=include, all=all, $
          sample=sample, offset=offset, select=select, unotes=unotes, indices=indices, $
          flags=flags, fnotes=fnotes)
   text = append_array(text, _text)
  end

 return, text
end
;=============================================================================



