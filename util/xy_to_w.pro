;==============================================================================
; xy_to_w
;
;
;==============================================================================
function xy_to_w, im, p, sx=sx, sy=sy, unique=unique, clip=clip, sub=sub
COMPILE_OPT strictarr			; needed for call to unique() below

 if(n_elements(im) EQ 2) then $
  begin
    sx = im[0]
    sy = im[1] 
  end $
 else $
  begin
   s = size(im)
   if(NOT keyword_set(sx)) then sx = s[1]
   if(NOT keyword_set(sy)) then sy = s[2]
  end
 n = sx*sy

; w = long(p[0,*] + p[1,*]*sx)
; w = round(p[0,*] + p[1,*]*sx)
 w = long(p[0,*]) + long(p[1,*]*sx)

 if(keyword_set(unique)) then w = unique(w, sub=sub)

 if(keyword_set(clip)) then $
  begin
   ii = where((w GE 0) AND (w LT n))
   if(ii[0] NE -1) then $
    begin
     w = w[ii]
     sub = sub[ii]
    end
  end

 return, reform(w)
end
;==============================================================================



;==============================================================================
; xy_to_w
;
;
;==============================================================================
function _xy_to_w, im, p

 if(n_elements(im) EQ 2) then dim = im $
 else dim = size(im, /dim)

 w = long(p[0,*] + p[1,*]*dim[0])

 return, w
end
;==============================================================================
