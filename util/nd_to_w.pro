;==============================================================================
; nd_to_w
;
;  p is [nd,n]
;
;==============================================================================
function nd_to_w, dim, p, unique=unique, clip=clip, sub=sub
COMPILE_OPT strictarr			; needed for call to unique() below

 nd = (size(p, /dim))[0]

 w = 0
 for i=0, nd-1 do $
  begin
   x = p[i,*]
   if(i GT 0) then x = x*long(product(dim[0:i-1]))
   w = w + x
  end

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

 return, reform(round(w))
end
;==============================================================================



