;=============================================================================
;+
; NAME:
;	swapgen
;
;
; PURPOSE:
;	Generates an array of subscripts to swap the desired columns or rows
;	in an array with dimensions n x m.
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = swapgen(n, m, w1, w2)
;
;
; ARGUMENTS:
;  INPUT:
;	n,m:		Dimensions of array from which to select.
;
;	w1,w2:		Indices of column or rows to swap.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	column:		If set, columns are swapped (default).
;
;	row:		If set, rows are swapped.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n x m) of subscripts that will swap the rows or columns.
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
function swapgen, n, m, w1, w2, row=row, column=column

 ww = lindgen(n, m)

 if(keyword_set(row)) then $
  begin
   row1 = ww[*,w1]
   row2 = ww[*,w2]
   ww[*,w1] = row2
   ww[*,w2] = row1
  end $ 
 else $
  begin
   col1 = ww[w1,*]
   col2 = ww[w2,*]
   ww[w1,*] = col2
   ww[w2,*] = col1
  end 

 return, ww
end
;=============================================================================
