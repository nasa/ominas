;===============================================================================
; sizeof
;
;===============================================================================
function sizeof, x, type=type

 if(keyword_set(type)) then typ = x $
 else typ = size(x, /type)

 case typ of
  0 :	return, -1
  1 :	return, 1
  2 :	return, 2
  3 :	return, 4
  4 :	return, 4
  5 :	return, 8
  6 :	return, 8
  7 :	return, 1
  8 :	return, -1
  9 :	return, 16
  10 :	return, -1
  11 :	return, -1
  12 :	return, -1
  13 :	return, -1
  14 :	return, 8
  15 :	return, 8
 endcase


end
;===============================================================================
