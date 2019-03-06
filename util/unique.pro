;=============================================================================
;+
; NAME:
;	unique
;
;
; PURPOSE:
;	Returns unique elements of an array.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = unique(array, s)
;
;
; ARGUMENTS:
;  INPUT: 
;       array:
;		Array to process.
;
;	s:	Array of sorted subscripts.  If given, these subscripts
;		are used to sort the array instead of peforming a sort
;		operation.
;
;  OUTPUT: 
;	s:	Sorted subsctripts.
;
;
; KEYWORDS:
;  INPUT:
;	nosort:	If set, the input array is not sorted.
;
;	desort:	If set, the output array is returned in original order.
;
;  OUTPUT: 
;	reverse_indices:			
;		Array of subscripts mapping the output elements to their
;		original positions in the input array.
;
;	subscripts:			
;		Array of subscripts giving the elements of array that were
;               returned.
;
;
; RETURN:
;	Unique array elements.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
function unique, _x, ss, nosort=nosort, desort=desort, reverse_indices=iii, subscripts=subscripts

 reverse = arg_present(iii)

 n = n_elements(_x)
 if(keyword_set(nosort)) then x = _x $
 else $
  begin
   if(NOT keyword_set(ss)) then ss = sort(_x)
   x = _x[ss]

   if(reverse) then sss = nwhere(ss, lindgen(n))	; reverse indices for ss
  end

 ii = x EQ shift(x, -1)
 uu = where(ii EQ 0)

 if(reverse) then $
  begin
   uuu = long(total(1-ii, /cum))
   uuu = [0,uuu[0:n-2]]
   uuu = reform(uuu, size(_x, /dim), /over)		; reverse indices for uu

   iii = uuu
   if(defined(sss)) then iii = uuu[sss]
  end

 subscripts = ss[uu]
 result = x[uu]

 if(keyword_set(desort)) then $
  begin
   qq = sort(subscripts)
   subscripts = subscripts[qq]
   result = result[qq]
  end

 return, result
end
;================================================================================
