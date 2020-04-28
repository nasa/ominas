;=============================================================================
; str_nnsplit
;
;=============================================================================
function str_nnsplit, strings, token, remainder=remainder, pos=i

 ns = n_elements(strings)
 result = strarr(ns)

 ;--------------------------------
 ; get first piece
 ;--------------------------------
 bb = byte(strings)
 nb = n_elements(bb)/ns

 if(NOT keyword_set(i)) then $
  begin
   w = where(bb EQ (byte(token))[0])
   if(w[0] EQ -1) then $
    begin
     remainder = strings
     return, result
    end
   i = w mod nb
;   ii = fix(w/nb)
   ii = long(w/nb)
  end $
 else ii = lindgen(ns)

 xx = ii[uniq(ii)]
 nn = n_elements(ii)

 bbb = bytarr(nb,ns)
 bbb[*,xx] = bb[*,xx]

 iii = rotate(ii,2)
 xxx = rotate([nn-uniq(iii)-1], 2)
 yy = i[xxx]
 yyy = yy + xx*nb


 bbb[yyy] = 0
 result = string(bbb)


 ;--------------------------------
 ; get remainder
 ;--------------------------------
 if(arg_present(remainder)) then $
  begin
   cc = bb
   cc[yyy] = 200
   ccc = rotate(cc,5)
   w = where(ccc EQ 0)
   if(w[0] NE -1) then ccc[w] = byte(' ')
   w = where(ccc EQ 200)
   if(w[0] NE -1) then ccc[w] = 0
   ss = strtrim(string(ccc),2)

   ccc = rotate(byte(ss),5)
   w = where(ccc EQ 0)
   if(w[0] NE -1) then ccc[w] = byte(' ')
   remainder = strtrim(string(ccc), 2)
  end


 result = string(bbb)
 return, result
end
;=============================================================================
