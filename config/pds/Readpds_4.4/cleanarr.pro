;------------------------------------------------------------------------------
; NAME: CLEANARR
;     
; PURPOSE: To remove all unprintable characters from the given string
; 
; CALLING SEQUENCE: Result = CLEANARR (textarr, [/SPACE])
; 
; INPUTS:
;    Text: array of scalar strings of characters to be cleaned
; OUTPUTS:
;    Result: array of scalar string of characters removed of all unprintable 
;            characters
;
; OPTIONAL INPUTS:
;    SPACE: removes all unprintable characters including all space chars.
;
; EXAMPLE:
;    To remove all unprintable chars except space
;       IDL> arr = ['the [tab]file','is [lf][cr]']
;       IDL> word = CLEANARR (arr)
;       IDL> print, word
;            the file is
;    To remove all unprintable chars including space
;       IDL> word = CLEANARR (arr,/SPACE)
;       IDL> print, word
;            thefile is
;
; PROCEDURES USED: CLEAN
;
; MODIFICATION HISTORY:
;    Written by: Puneet Khetarpal [October 2, 2003]
;    For a complete list of modifications, see changelog.txt file.
;
;------------------------------------------------------------------------------

function cleanarr, textarr, SPACE = space
   ; determine whether space keyword is set:
   space = keyword_set(space)

   ; determine the type and dimensions of textarr:
   stat = size(textarr)
   dim = stat[0]
   if (dim eq 1) then begin  ; clean array for 1-D array
      i = long(0)
      imax = stat[1] - 1
      while (i le imax) do begin
         textarr[i] = (space) ? clean(textarr[i], /space) : clean(textarr[i])
         i += 1
      endwhile
   endif else if (dim eq 2) then begin   ; clean array for 2-D array
      i = long(0)
      j = long(0)
      imax = stat[1] - 1
      jmax = stat[2] - 1
      while (i le imax) do begin
         while (j le jmax) do begin
            textarr[i,j] = (space) ? clean(textarr[i,j], /space) : $
                                     clean(textarr[i,j])
            j += 1
         endwhile
         i += 1
      endwhile
   endif else if (dim eq 0) then begin  ; clean array of scalar string
      textarr = (space) ? clean(textarr, /space) : clean(textarr)
   endif

   return, textarr   
end
