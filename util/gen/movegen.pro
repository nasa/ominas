;=============================================================================
;+
; NAME:
;	movegen
;
;
; PURPOSE:
;	Generates an array of subscripts to move the desired column or row
;	in an array with dimensions n x m.
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = movegen(n, m, w1, w2)
;
;
; ARGUMENTS:
;  INPUT:
;	n,m:		Dimensions of array from which to select.
;
;	w1:		Index of column or row to move.
;
;	w2:		Index giving new position of column or row.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	column:		If set, a column is moved (default).
;
;	row:		If set, a row is moved.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n x m) of subscripts that will move the row or column.
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function movegen, n, m, w1, w2, row=row, column=column

 ww = lindgen(n, m)

 if(keyword_set(row)) then $
  begin
   row = ww[*,w1]					; extract row to move
   if(w2 LT w1) then ww[*,w2+1:w1] = ww[*,w2:w1-1] $	; shift rows to fill old 
   else ww[*,w1:w2-1] = ww[*,w1+1:w2]			;  row and open new row
   ww[*,w2] = row					; insert row at new loc
  end $ 
 else $
  begin
   col = ww[w1,*]					; extract col to move
   if(w2 LT w1) then ww[w2+1:w1,*] = ww[w2:w1-1,*] $	; shift cols to fill old 
   else ww[w1:w2-1,*] = ww[w1+1:w2,*]			;  col and open new col
   ww[w2,*] = col					; insert col at new loc
  end 

 return, ww
end
;=============================================================================
