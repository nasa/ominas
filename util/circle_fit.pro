;============================================================================
; cf_fn
;
;============================================================================
pro cf_fn, i, parm, f
common cf_block, x, y, fixa, fixr, fixb, a0, b0, r0

 a = a0 & b = b0 & r = r0

 k = 0
 if(NOT keyword_set(fixa)) then $
  begin
   a = parm[k]
   k = k + 1
  end
 if(NOT keyword_set(fixb)) then $
  begin
   b = parm[k]
   k = k + 1
  end
 if(NOT keyword_set(fixr)) then $
  begin
   r = parm[k]
   k = k + 1
  end


 f = r - sqrt((x[i]-a)^2 + (y[i]-b)^2)
end
;============================================================================



;============================================================================
; circle_fit
;
;============================================================================
pro circle_fit, _x, _y, sigx, sigy, fixa=_fixa, fixb=_fixb, fixr=_fixr, $
                a=a, b=b, r=r, siga=siga, sigb=sigb, sigr=sigr
common cf_block, x, y, fixa, fixr, fixb, a0, b0, r0

 if(NOT keyword_set(_fixa)) then _fixa = 0
 if(NOT keyword_set(_fixb)) then _fixb = 0
 if(NOT keyword_set(_fixr)) then _fixr = 0

 x = _x & y = _y & fixa = _fixa & fixb = _fixb & fixr = _fixr

 n = double(n_elements(x))
 i = dindgen(n)

 if(NOT defined(a)) then a = total(x)/n
 if(NOT defined(b)) then b = total(y)/n
 rr = sqrt((x-a)^2 + (y-b)^2)
 if(NOT defined(r)) then r = total(rr)/n

 a0 = a & b0 = b & r0 = r

 if(NOT keyword_set(fixa)) then parm = append_array(parm, a)
 if(NOT keyword_set(fixb)) then parm = append_array(parm, b)
 if(NOT keyword_set(fixr)) then parm = append_array(parm, r)

 sig = make_array(n, val=1d)
 if(keyword_set(sigx)) then sig = sigx
 if(keyword_set(sigy)) then sig = sqrt(sigx^2 + sigy^2)

 z = curvefit(i, dblarr(n), 1d/sig^2, parm, sigparm, chisq=chisq, /noder, fun='cf_fn')

 k = 0
 if(NOT keyword_set(fixa)) then $
  begin
   a = parm[k]
   k = k + 1
  end
 if(NOT keyword_set(fixb)) then $
  begin
   b = parm[k]
   k = k + 1
  end
 if(NOT keyword_set(fixr)) then $
  begin
   r = parm[k]
   k = k + 1
  end


 sig = (sigb = (sigr = 0d))
 k = 0
 if(NOT keyword_set(fixa)) then $
  begin
   siga = sigparm[k]
   k = k + 1
  end
 if(NOT keyword_set(fixb)) then $
  begin
   sigb = sigparm[k]
   k = k + 1
  end
 if(NOT keyword_set(fixr)) then $
  begin
   sigr = sigparm[k]
   k = k + 1
  end


end
;============================================================================

