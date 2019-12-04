;===============================================================================
; strcat_common_names
;
;  This code is from Jaquelyn Ryan and was extracted from the star translators
;  and saved here whem I re-implemented this functionality as a separate 
;  translator.
;
;===============================================================================
pro strcat_common_names, stars, name


 ;---------------------------------------------------------
 ; Input common names. Star names are found via an 
 ; internal document which is cross indexed with several 
 ; catalogs. UCAC occupies the sixth column of that
 ; document.
 ;---------------------------------------------------------
 file = file_search(getenv('OMINAS_DIR')+'/config/strcat/stars-orig.txt')
 openr, lun, file, /get_lun
 line = ''
 linarr = strarr(file_lines(file), 7)
 i = 0
 while not eof(lun) do $
  begin
   readf, lun, line
   fields = strsplit(line, ';', /extract)
   linarr[i, *] = fields
   i = i + 1
  endwhile
 free_lun, lun

 n = n_elements(stars)
 matches = intarr(n)
 ;---------------------------------------------------------
 ; Match names with the sixth column (UCAC)
 ;---------------------------------------------------------
 for i=0, n - 1 do matches[i] = where(strpos(linarr[*,5], stars[i].num) ne -1)
 ndx = where(matches ne -1)
 matches = matches[ndx]
 for i = 0, n_elements(matches) - 1 do $
  begin
    lin_ndx = matches[i]
    if strtrim(linarr[lin_ndx, 1], 2) ne '-1' then name[ndx[i]] = linarr[lin_ndx, 1]
    if strtrim(linarr[lin_ndx, 0], 2) ne '-1' then name[ndx[i]] = linarr[lin_ndx, 0]
  endfor


end
;===============================================================================
