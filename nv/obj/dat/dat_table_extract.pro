;=============================================================================
; dat_table_extract
;
;=============================================================================
function dat_table_extract, table, match, ncol, keyvals=keyvals

 if(NOT keyword_set(table)) then return, ''

 marker='-'

 matches = table[*,0]
 w0 = (where(matches EQ match))[0]


 ;================================================================
 ; extract all given items and keyvals for this match
 ;================================================================
 if(w0[0] EQ -1) then return, ''

 w1 = w0
 wn = where(matches[w0:*] NE marker)
 wc = where(matches[w0:*] EQ marker)
 if(wc[0] NE -1) then $
  begin
   if(n_elements(wn) GT 1) then w1 = w0 + wn[1]-1 $
   else w1 = w0 + n_elements(wc)
  end

 ww = lindgen(w1-w0+1)+w0

 items = table[ww,1:ncol]

 s = size(table)
 nfields = s[2]
 ninst = s[1]
 if(nfields GT ncol+1) then keyvals = table[ww,ncol+1:nfields-1]


 ;================================================================
 ; remove matched match from table
 ;================================================================
 ii = indgen(ninst)
 ii = rm_list_item(ii, ww, only=-1) 
 if(ii[0] EQ -1) then table = '' $
 else table = table[ii,*]


 ;================================
 ; filter out any place markers
 ;================================
 items = strtrim(strep_char(items, '-', ' '), 2)


 ;================================
 ; reduce keyvals
 ;================================
; keyvals = str_cull(keyvals)


 return, items
end
;=============================================================================


