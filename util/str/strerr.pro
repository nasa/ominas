;===============================================================================
; strerr_dec
;
; determine decimal location in string; add decimal at end if needed
;
;===============================================================================
function strerr_dec, s

 p = strpos(s, '.')
 if(p[0] EQ -1) then $
  begin
   p = [strlen(s)]
   s = s + '.'
  end

 return, p
end
;===============================================================================



;===============================================================================
; strerr_exp
;
; determine exponent
;
;===============================================================================
function strerr_exp, x

 lx = alog10(x)
 snx = sign(lx)
 ex = snx*ceil(abs(lx))

 return, double(ex)
end
;===============================================================================



;===============================================================================
; strerr_shift
;
;===============================================================================
pro strerr_shift, s, sd, n


 ss = str_compress(strep_char(s, '.', ' ' ), /rem)
 
 p = strerr_dec(s)
 pos = p+n

 if(pos LT strlen(ss)) then $
               s = strmid(ss, 0, pos) + '.' + strmid(ss, pos, strlen(ss)+1) $
 else $
  begin
   s = str_pad(ss, pos - (strlen(ss)-p), c='0')
   sd = str_pad(sd, n+1, c='0')
  end


 if(strmid(s, 0, 1) EQ '.') then s = '0' + s
end
;===============================================================================



;===============================================================================
; strerr
;
;
;===============================================================================
function strerr, x, dx

 if(dx EQ 0) then return, strtrim(x,2)

 ;-------------------------------
 ; find multiplier and round sdx 
 ;-------------------------------
 edx = strerr_exp(dx)

 if(edx LT 0) then mult = 10^(-edx) $
 else mult = 10^(1-edx)
 mult = double(mult)

 dxx = round(mult*dx)

 if(dxx EQ 10) then $
  begin
   mult = mult/10
   dxx = 1
  end
 n = alog10(mult)

 sdxx = strmid(strtrim(dxx,2), 0, 1)


 ;-------------------------------
 ; round x and trim
 ;-------------------------------
 xx = round(x*mult)/mult
 sxx = strtrim(xx,2)

 p = strpos(sxx, '.')
 sxx = strmid(sxx, 0, p+n+1)


 ;-----------------------------------------------
 ; adjust sdxx if decimal moved to the right
 ;-----------------------------------------------
 if(n LT 0) then sdxx = str_pad(sdxx, 1-n, c='0')


 ;-----------------------------------------------
 ; Fix decimals on either end
 ;-----------------------------------------------
 if(strmid(sxx, 0, 1) EQ '.') then sxx = '0' + sxx
 if(strmid(sxx, strlen(sxx)-1, 1) EQ '.') then sxx = strmid(sxx, 0, strlen(sxx)-1)


 return, sxx + '(' + sdxx + ')'
end
;===============================================================================
