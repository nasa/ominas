;=============================================================================
; csrl_label_struct__define
;
;=============================================================================
pro csrl_label_struct__define

 struct = $
   { csrl_label_struct, $
	file		:	'', $
	good		:	0, $
	deliv		:	0d, $
	start_jd	:	0d, $
	stop_jd		:	0d, $
	type		:	'', $
	version		:	'', $
	descr		:	'', $
	targets_p	:	nv_ptr_new() $
   }

end
;=============================================================================



;=============================================================================
; csrl_getpar
;
;=============================================================================
function csrl_getpar, label, keyword

 ;------------------------------
 ; find start of keyword
 ;------------------------------
 ll = strlen(keyword)
 w = where(strmid(label, 0, ll) EQ keyword)
 if(w[0] EQ -1) then return, ''

 ;------------------------------
 ; find end of keyword
 ;------------------------------
 lab = label[w[0]:*]
 ww = where(strmid(lab, 0, 1) NE ' ')
 lines = lab[0:ww[1]-1]
 nlines = n_elements(lines)

 ;------------------------------
 ; remove '='
 ;------------------------------
 p = strpos(lines[0], '=')
 lines[0] = strmid(lines[0], p+1, strlen(lines[0])-p-1) 

 ;------------------------------
 ; parse list
 ;------------------------------
 line = lines[0]
 for i=1, nlines-1 do line = line + lines[i]
 line = strep_char(line, '{', ' ')
 line = strep_char(line, '}', ' ')
 line = strep_char(line, '"', ' ')
 line = strep_char(line, "'", ' ')
 values = strtrim(str_nsplit(line, ','),2)


 return, values
end
;=============================================================================



;=============================================================================
; csrl_time_to_jd
;
;=============================================================================
function csrl_time_to_jd, time

 yy = (fix(strmid(time, 0, 4)))[0]
 mon = (fix(strmid(time, 5, 2)))[0]
 dd = (fix(strmid(time, 8, 2)))[0]
 hh = (fix(strmid(time, 11, 2)))[0]
 mm = (fix(strmid(time, 14, 2)))[0]
 ss = (fix(strmid(time, 17, 2)))[0]

 jd = julday(mon, dd, yy, hh, mm, ss)


 return, jd
end
;=============================================================================



;=============================================================================
; cas_spice_read_labels
;
;=============================================================================
function cas_spice_read_labels, files

 nfiles = n_elements(files)
 data = replicate({csrl_label_struct}, nfiles)

 label_files = files + '.lbl'

 for i=0, nfiles-1 do $
  begin
   label = read_txt_file(label_files[i], status=status)
   if(status NE -1) then $
    begin
     start_time = csrl_getpar(label, 'START_TIME')
     if(keyword__set(start_time)) then $
      begin
       stop_time = csrl_getpar(label, 'STOP_TIME')
       targets = csrl_getpar(label, 'TARGET_NAME')

       data[i].file = files[i]
       data[i].start_jd = csrl_time_to_jd(start_time)
       data[i].stop_jd = csrl_time_to_jd(stop_time)
       data[i].targets_p = nv_ptr_new(targets)
      end
    end
  end


 return, data
end
;=============================================================================



