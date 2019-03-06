;=============================================================================
;+
; NAME:
;	nv_help
;
;
; PURPOSE:
;	Prints information about OMINAS and its objects.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_help, p
;
;
; ARGUMENTS:
;  INPUT:
;	p:	Object to query.  Actions that depend on this input are
;		as follows:
;
;		 p		action
;		 ----------------------------------------------------
;		 No value	Print the full paths of all NV tables. 
;		 Numeric	Call IDL function 'help'.
;		 Ptr or struct	Descend recursively, printing info on all
;				fields.
;		 String		Assumes p is the name of an OMINAS routine
;				and prints the documentation page if
;				available.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;       event:		If set, the event tables are printed and p
;			is ignored.
;
;       print:		If set, any arrays with this many elements or fewer
;			are printed out.  Default is 100.
;
;	tables:		If set, and if the input object is a data descriptor,
;			then the I/O, translators, and transforms tables
;			for that object are printed.
;
;  OUTPUT: 
;       capture:	If present, the output in returned in this
;			keyword instead of being printed.
;
;
; ENVIRONMENT VARIABLES:
;       OMINAS_DIR:	OMINAS top directory; used to find documentation files.
;
;
; RETURN: NONE
;
;
; STATUS:
;       The routine help is currently not working because it relied on the old
;       documentation system.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================



;===========================================================================
; nv_help_print
;
;===========================================================================
pro nv_help_print, s, indent=indent, capture=capture, nocrlf=nocrlf
 if(NOT keyword_set(s)) then s = ''

 if(keyword_set(indent)) then s = str_pad(' ', indent) + s

 if(defined(capture)) then $
  begin
   if(n_elements(size(s, /dim)) GT 1) then s = tr(s)
   capture = append_array(capture, s)
   return
  end 

 if(keyword_set(nocrlf)) then print, s, format='(a, $)' $
 else print, s
end
;===========================================================================


;===========================================================================
; nv_sep
;
;===========================================================================
pro nv_help_sep, capture=capture

 nv_help_print, capture=capture, $
   '-------------------------------------------------------------------------------'

end
;===========================================================================


;===========================================================================
; nv_help_state
;
;===========================================================================
pro nv_help_state, capture=capture
@nv_block.common

 nv_help_print, 'Translators tables:', capture=capture
 nv_help_print, '   ' + transpose([*nv_state.translators_filenames_p]), capture=capture
 nv_help_print, capture=capture

 if(keyword__set(*nv_state.transforms_filenames_p)) then $
  begin
   nv_help_print, 'Transforms tables:', capture=capture
   nv_help_print, '   ' + transpose([*nv_state.transforms_filenames_p]), capture=capture
   nv_help_print, capture=capture
  end

 nv_help_print, 'I/O Tables:', capture=capture
 nv_help_print, '   ' + transpose([*nv_state.io_filenames_p]), capture=capture
 nv_help_print, capture=capture

 nv_help_print, 'Filetype tables:', capture=capture
 nv_help_print, '   ' + transpose([*nv_state.ftp_detectors_filenames_p]), capture=capture
 nv_help_print, capture=capture

 nv_help_print, 'Instrument detector tables:', capture=capture
 nv_help_print, '   ' + transpose([*nv_state.ins_detectors_filenames_p]), capture=capture

end
;===========================================================================



;===========================================================================
; nv_help_descend
;
;===========================================================================
pro nv_help_descend, dp0, indent, capture=capture, print=print, $
                                                   level=level0, max=max
 pad = 20
 offset = 2

 if(NOT keyword_set(level0)) then level0 = 0
 level = level0 + 1
 if(keyword_set(max)) then if(level GT max) then return

 dp = dp0
 type = size(dp, /type)
 dim = size(dp, /dim)
 n = n_elements(dp)


 ;----------------------------------------
 ; Object: dereference and descend.  
 ;----------------------------------------
 if(type EQ 11) then $
  begin
   for i=0, n-1 do $
    begin
     if(NOT obj_valid(dp[i])) then $
      begin
       nv_help_print, indent=indent, '<NullObject>', capture=capture
       return
      end

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Print the object reference.
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if((i NE 0) AND (level GT 1)) then $
         nv_help_print, indent=indent-offset, str_pad(' ', pad), capture=capture, /nocrlf
     nv_help_print, indent=indent, string(dp[i], /print), capture=capture

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Descend into the object unless it's an OMINAS object; 
     ; in that case, only descend from the first level,
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     _dp = cor_dereference(dp[i])
     if((NOT cor_test(dp[i])) OR (level EQ 1)) then $
       nv_help_descend, _dp, indent+offset, capture=capture, print=print, level=level, max=max
    end
   return
  end


 ;----------------------------------------
 ; Pointer: dereference and descend 
 ;----------------------------------------
 if(type EQ 10) then $
  begin
   for i=0, n-1 do $
    begin
     if(NOT ptr_valid(dp[i])) then $
      begin
       nv_help_print, indent=indent, '<NullPointer>', capture=capture
       return
      end

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Print the pointer reference.
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(i NE 0) then $
         nv_help_print, indent=indent-offset, str_pad(' ', pad), capture=capture, /nocrlf
     nv_help_print, indent=indent, string(dp[i], /print), capture=capture

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Descend into the pointer.
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     val = *dp[i]
     nv_help_descend, val, indent+offset, capture=capture, print=print, level=level, max=max
    end
   return
  end


 ;--------------------------------------------
 ; Structure -- print tag names and descend
 ;--------------------------------------------
 if(type EQ 8) then $
  begin
   for j=0, n-1 do $
    begin
     s = dp[j]
     tags = tag_names(s)
     ntags = n_elements(tags)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Print structure description
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     help, dp, out=out
     ss = strsplit(strtrim(out[0],2), ' ', /extract)
     nv_help_print, indent=indent, strjoin(ss[1:*], ' '), capture=capture

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Print each tag name and descend, ignoring IDL object fields
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     for i=0, ntags-1 do $
      begin
       if(NOT set_member(tags[i], $
             ['IDL_OBJECT_TOP', 'IDL_OBJECT_BOTTOM', '__OBJ__'])) then $
        begin
         nv_help_print, indent=indent, str_pad(tags[i], pad), capture=capture, /nocrlf
         nv_help_descend, s.(i), indent+offset, capture=capture, print=print, level=level, max=max
        end
      end
    end
   return
  end


 ;------------------------------------------------------------------------
 ; other types -- print type and value, possibly with some processing
 ;------------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; print description
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
 help, dp, out=out
 ss = strsplit(strtrim(out,2), ' ', /extract)
 ss = strjoin(ss[1:*])

 if((type EQ 7) AND (dim[0] EQ 0)) then $
                         junk = str_nnsplit(strtrim(out,2), '=', rem=ss)
 
 nv_help_print, indent=indent, ss, capture=capture
 

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; print array values if /print and # elements less than specified value,
 ; and not a scalar
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(print)) then $
  if(n LE print) then $
   if(dim[0] NE 0) then $
    begin
    if(type EQ 7) then ss = "'" + string(dp) + "'" $
    else ss = string(dp, /print)
    nv_help_print, indent=indent, transpose([ss]), capture=capture
   end


end
;===========================================================================



;===========================================================================
; nv_help_dump_events
;
;===========================================================================
pro nv_help_dump_events, capture=capture, items

 if(NOT keyword_set(items)) then $
  begin
   nv_help_print, capture=capture, 'No entries'
   return
  end

 n = n_elements(items) 
 i = 0l
 repeat $
  begin
   xd = items[i].xd

   desc = cor_name(xd)

   type = 'READ'
   if(items[i].type EQ 0) then type = 'WRITE'

   help, out=s, xd[0]
   ptr = str_flip(str_nnsplit(str_flip(s), ' '))

   s = str_pad(ptr, 32) + str_pad(type, 6) + $
       str_pad(desc, 20) + str_pad(items[i].handler, 29)

   nv_help_print, capture=capture, s

   i = i + 1
  endrep until(i GE n)


end
;===========================================================================



;===========================================================================
; nv_help_event
;
;===========================================================================
pro nv_help_event, capture=capture
@nv_notify_block.common

 ;-------------------------------------
 ; dump handler list
 ;-------------------------------------
 nv_help_print, capture=capture, 'Event Registry:'
 nv_help_sep, capture=capture
 nv_help_dump_events, capture=capture, list

 nv_help_print, capture=capture, ''

 ;-------------------------------------
 ; dump event buffer
 ;-------------------------------------
 nv_help_print, capture=capture, 'Event Buffer:'
 nv_help_sep, capture=capture
 nv_help_dump_events, capture=capture, buf

 

end
;===========================================================================



;===========================================================================
; nv_help_doc_parse
;
;===========================================================================
function nv_help_doc_parse, lines

 delim = '___________________________'

 w = where(strpos(lines, delim) EQ 0)

 if(w[0] NE -1) then $
  begin
   doc_lines = list()
   for i=0, n_elements(w)-1, 2 do doc_lines.add, lines[w[i]+1:w[i+1]-1]
   return, doc_lines
  end


 return, !null
end
;===========================================================================



;===========================================================================
; nv_help_doc
;
;===========================================================================
pro nv_help_doc, iname, capture=capture

 name = strlowcase(iname)

 ;------------------------------------------------------
 ; print the path to the source file
 ;------------------------------------------------------
 which, name, out=s
 nv_help_print, s, capture=capture

 ;------------------------------------------------------
 ; find the doc files
 ;------------------------------------------------------
 doc_dir = getenv('OMINAS_DIR') + '/docs/rst/'
 doc_files = file_search(doc_dir,'*.txt')
 doc_pfs = str_nnsplit(str_flip(str_nnsplit(str_flip(doc_files), '_')), '.')


 ;------------------------------------------------------------------------
 ; search the documentation
 ;------------------------------------------------------------------------
 n = n_elements(doc_files)

 for i=0, n-1 do $
  begin
   lines = read_txt_file(doc_files[i], /raw)
   docs = nv_help_doc_parse(lines)
   if(keyword_set(docs)) then for j=0, n_elements(docs)-1 do $
    begin
     doc_lines = docs[j]
     w = where(strpos(doc_lines, iname) EQ 0)
     if(w[0] NE -1) then $
      begin
       nv_help_print, tr(doc_lines[3:*]), capture=capture
       return
      end
    end

  end

 
 nv_message, 'No documentation available for ' + name + '.'

end
;===========================================================================



;===========================================================================
; nv_help_doc
;
;===========================================================================
pro __nv_help_doc, iname, capture=capture

 ;------------------------------------------------------
 ; find the doc files
 ;------------------------------------------------------
 doc_dir = getenv('OMINAS_DIR') + '/docs/rst/'
 doc_files = file_search(doc_dir,'*.txt')
 doc_pfs = str_nnsplit(str_flip(str_nnsplit(str_flip(doc_files), '_')), '.')


 ;------------------------------------------------------------------------
 ; search the documentation
 ;------------------------------------------------------------------------
 n = n_elements(doc_files)

 for i=0, n-1 do $
  begin
   lines = read_txt_file(doc_files[i], /raw)
   lines=strtrim(lines,2)
   nlines=list()
   prevl='a'
   foreach line,lines,iline do begin
    if (strlen(line) eq 0) && (strlen(prevl) eq 0) then continue
    nlines.add,strjoin(strsplit(line,'\\_',/regex,/extract),'_')
    prevl=line
   endforeach
   lines=nlines.toarray()

   ;name = strupcase(name)
   name=strlowcase(iname)
   ;name=strjoin(strsplit(name,'_',/extract),'\_')

   p = strpos(lines, name)
   w = where(p EQ 0)
   w = where(stregex(lines,'^'+name+'(\.pro)?',/boolean))
   if(w[0] NE -1) then $
    begin
     ii = w[0]
     if stregex(strtrim(lines[ii],2),'^'+name+'(\.pro)?',/boolean) then $
      begin
       ;p = strpos(lines[ii+2:*], '-')
       nn = min(where(p EQ 0))
       w=where(stregex(lines,'^(__)|(==)',/boolean))
       nn=min(w)
       if(nn EQ -1) then nn = n_elements(lines) - ii

       ;- - - - - - - - - - - - - - - - - - - - - - -
       ; extract relevant lines
       ;- - - - - - - - - - - - - - - - - - - - - - -
       doc_lines = lines[ii:ii+nn-2]

       ;- - - - - - - - - - - - - - - - - - - - - - -
       ; get rid of trailing blank lines
       ;- - - - - - - - - - - - - - - - - - - - - - -
       w = max(where(strtrim(doc_lines, 2) NE ''))
       if(w[0] NE -1) then doc_lines = doc_lines[0:w[0]]

;       nv_help_sep, capture=capture
       nv_help_print, tr(doc_lines), capture=capture
       return
      end
    end
  end

 
 nv_message, 'No documentation available for ' + name + '.'

end
;===========================================================================



;===========================================================================
; nv_help_tables
;
;===========================================================================
pro nv_help_tables, dp, capture=capture

 nv_help_print, capture=capture, 'I/O table:'
 nv_help_sep, capture=capture
 nv_help_print, transpose(dat_table(dp, /io, indent=2)), capture=capture
 nv_help_print, '', capture=capture
 nv_help_print, '', capture=capture

 nv_help_print, capture=capture, 'Translators table:'
 nv_help_sep, capture=capture
 nv_help_print, transpose(dat_table(dp, /translators, indent=2)), capture=capture
 nv_help_print, '', capture=capture
 nv_help_print, '', capture=capture

 nv_help_print, capture=capture, 'Transforms table:'
 nv_help_sep, capture=capture
 nv_help_print, transpose(dat_table(dp, /transforms, indent=2)), capture=capture
 nv_help_print, '', capture=capture
 nv_help_print, '', capture=capture

end
;===========================================================================



;===========================================================================
; nv_help
;
;===========================================================================
pro nv_help, dp, capture=capture, print=print, event=event, tables=tables

 if(keyword_set(print)) then if(print EQ 1) then print = 100
 nv_help_print, '', capture=capture


 ;--------------------------------------------
 ; show event info if /event
 ;--------------------------------------------
 if(keyword_set(event)) then $
  begin
   nv_help_event, capture=capture
   return
  end

 ;----------------------------------------------------
 ; print documentation if argument is a string
 ;----------------------------------------------------
 if(size(dp, /type) EQ 7) then $
  begin
   nv_help_doc, dp, capture=capture
   return
  end

 ;---------------------------------------------------------
 ; print tables if /tables and object is data descriptor
 ;---------------------------------------------------------
 if(keyword_set(tables)) then $
  begin
   if(cor_class(dp) NE 'DATA') then $
                  nv_message, '/tables keyword only applies to data objects.'

   nv_help_tables, dp, capture=capture
   return
  end


 ;----------------------------------------------------
 ; otherwise describe the object
 ;----------------------------------------------------
; nv_help_sep, capture=capture
 if(keyword_set(dp)) then nv_help_descend, dp, 0, capture=capture, print=print $
 else nv_help_state, capture=capture


 nv_help_print, capture=capture

end
;===========================================================================



