;=============================================================================
;+
; NAME:
;       nmin
;
;
; PURPOSE:
;       Finds minimum values within many arrays.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = nmin(array, direction, subscripts=subscripts)
;
;
; ARGUMENTS:
;  INPUT:
;         array:  Array to search for minimum values.
;
;     direction:  Dimension to search.
;
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;    subscripts: Coordinate of each minimum value relative to the 
;                scanning dimension.
;
;
; RETURN:
;       An array of minimum values.  
;
; EXAMPLE:
;	If x is an array with dimensions (d0,d1,d2), then the command 
;
;		xm = nmin(x, 1, sub=sub)
;
;	returns an array with dimensions (d0,1,d2), where each value is 
;	the minimum value along the scanned direction (direction 1).   
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 1/2002
;
;-
;=============================================================================
function nmin, __array, dir, subscripts=subscripts, positive=positive

 if(NOT keyword_set(dir)) then dir = 0

 ;--------------------------------------------
 ; determine size and type of array
 ;--------------------------------------------
 s = size(__array)
 ndim = s[0]
 dim = s[1:ndim]
 type = s[ndim+1]

 ;--------------------------------------------
 ; check for trivial result
 ;--------------------------------------------
 if(dir EQ ndim) then $
  begin
   subscripts = lonarr(dim[0])
   return, __array
  end

 ;--------------------------------------------
 ; check for 1d array
 ;--------------------------------------------
 if(ndim EQ 1) then $
  begin
   return, min(__array)
  end

 ;--------------------------------------------
 ; transpose as needed
 ;-------------------------------------------- 
 if(dir NE 0) then $
  begin
   tp = lindgen(ndim)
   tp[0] = dir & tp[dir] = 0
   _array = transpose(__array, tp)
   s = size(_array)
   dim = s[1:ndim]
  end $
 else _array = __array


 ;--------------------------------------------
 ; scan over first dimension in the array
 ;--------------------------------------------
 n = dim[0]

 m = 1
 for i=1, ndim-1 do m = m*dim[i]

 array = reform(_array, n, m)

 mins = make_array(m, type=type)
 subscripts = lonarr(m)
 mins[*] = array[0,*]

 for i=1, n-1 do $
  begin
   if(keyword_set(positive)) then $
       w = where((array[i,*] LT mins) AND (array[i,*] GT 0)) $
   else w = where(array[i,*] LT mins)
   if(w[0] NE -1) then $
    begin
     mins[w] = array[i,w]
     subscripts[w] = i
    end
  end

 mins = reform(mins, [1, dim[1:*]], /over)
 subscripts = reform(subscripts, [1, dim[1:*]], /over)


 ;--------------------------------------------
 ; transpose back
 ;-------------------------------------------- 
 if(dir NE 0) then $
  begin
   mins = transpose(mins, tp)
   subscripts = transpose(subscripts, tp)
  end


 return, mins
end
;===========================================================================
