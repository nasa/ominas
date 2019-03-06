;===========================================================================
; spice_read_klist
;
;
;===========================================================================
function spice_read_klist, dd, klist, ck_out=ck_out, $
             time=time, prefix=prefix, inst=inst, notime=notime, extension=extension
common spice_klist_block, klist_last, _inlines

 if(NOT keyword_set(klist)) then return,''

 inst_prefix = prefix
 if(keyword_set(inst)) then inst_prefix = inst_prefix + '_' + inst

 ndd = n_elements(dd)

 ;--------------------------------------------
 ; read input file
 ;--------------------------------------------
 read = 0
 if(NOT keyword_set(_inlines)) then read = 1
 if(keyword_set(klist_last)) then if(klist NE klist_last) then read = 1
 if(read) then $
  begin
   inlines = strip_comment(read_txt_file(klist))
   klist_last = klist
   _inlines = inlines
   nv_message, /con, verb=0.2, 'Read kernel list file ' + klist + '.'
  end $
 else inlines = _inlines

 ;---------------------------------------------------------------------------
 ; truncate file at first occurrence of 'end' at beginning of line, if any
 ;---------------------------------------------------------------------------
 ww = where(strupcase(strmid(inlines, 0, 3)) EQ 'END')
 if(ww[0] ne -1) then inlines = inlines[0:ww[0]-1]


 ;--------------------------------------------
 ; scan input file, expanding expressions
 ;--------------------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; look for SET keyword at beginning of lines
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 wset = where(strpos(inlines, 'SET') EQ 0)
 if(wset[0] NE -1) then $
  begin
   setlines = inlines[wset]
   nset = n_elements(setlines)
   set = strcompress(strmid(setlines, 3, 1000), /remove_all)
   for i=0, nset-1 do setenv, set[i]
   inlines = rm_list_item(inlines, wset, only='')
  end


 nlines = n_elements(inlines)
 if(nlines EQ 0) then return, ''

 default_lines = (time_lines = '')
 standard_lines = inlines


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; look for DEFAULT keyword at beginning of lines
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 wdefault = where(strpos(inlines, 'DEFAULT') EQ 0)
 if(wdefault[0] NE -1) then $
  begin
   if(nlines GT wdefault[0]+1) then default_lines = inlines[wdefault[0]+1:*]
   standard_lines = standard_lines[0:wdefault[0]-1]
  end


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; look for TIME_START, TIME_STOP keywords at beginnings of lines
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 wstart = where(strpos(inlines, 'START_TIME') EQ 0)
 if(wstart[0] NE -1) then $
  begin
   standard_lines = standard_lines[0:wstart[0]-1]

   if(NOT keyword_set(notime)) then $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; look for stop times and include appropriate lines 
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
     wstop = where(strpos(inlines, 'STOP_TIME') EQ 0)
     if((wstop[0] EQ -1) OR $
         (n_elements(wstop) NE n_elements(wstart))) then $
           nv_message, klist + ': One STOP_TIME required for each START_TIME.'

     junk = str_nnsplit(inlines(wstart), '=', rem=start_times)
     junk = str_nnsplit(inlines(wstop), '=', rem=stop_times)

     et_start = spice_str2et(start_times)
     et_stop = spice_str2et(stop_times)

     w = where((et_start LT min(time)) AND (et_stop GT max(time)))
     if(w[0] NE -1) then time_lines = inlines[wstart[w[0]]+1:wstop[w[0]]-1]
    end

  end

 inlines = [standard_lines, time_lines]
 if(NOT keyword_set(time_lines)) then inlines = [inlines, default_lines]
 nlines = n_elements(inlines)


 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 ; scan the selected lines
 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 for i=0, nlines-1 do $
  begin
   line = inlines[i]
   if(keyword__set(line)) then $
    begin
     files = file_search(line)
     if(keyword__set(files)) then $
       outfiles = append_array(outfiles, files) $
     else nv_message, /con, 'Not found: ' + line
    end
  end
 if(NOT keyword_set(outfiles)) then return, ''




 ;--------------------------------------------
 ; remove degenerate slashes
 ;--------------------------------------------
 sep = path_sep()

 nfiles = n_elements(outfiles)
 for i=0, nfiles-1 do if(keyword__set(outfiles[i])) then $
  begin
   slash = 0
   if(strmid(outfiles[i], 0, 1) EQ sep) then slash = 1

   ss = strtrim(str_nsplit(outfiles[i], sep), 2)
   w = where(ss NE '')
   if(w[0] EQ -1) then outfiles[i] = '' $
;   else outfiles[i] = sep + str_cat(ss[w], ins=sep)
   else outfiles[i] = str_cat(ss[w], ins=sep)
   if(slash) then outfiles[i] = sep + outfiles[i]
  end


 ;--------------------------------------------
 ; select outfiles with specified extensions
 ;--------------------------------------------
 if(keyword_set(extension)) then $
  if(keyword_set(outfiles)) then $
   begin
    split_filename, outfiles, dir, name, ext
    w = nwhere(ext, extension)
    if(w[0] EQ -1) then outfiles = '' $
    else outfiles = outfiles[w]
   end


 return, outfiles
end
;===========================================================================
