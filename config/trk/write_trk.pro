;=============================================================================
; write_trk
;
;
;=============================================================================
pro write_trk, filename, et, data, ra=ra, dec=dec, target=target, $ 
                    station=station

 dat = [tr(et), tr(data)]

 label = ''
 vicsetpar, label, 'STATION', station
 if(keyword_set(ra)) then $
      vicsetpar, label, 'RA', strtrim(string(ra, form='(d20.10)'),2)
 if(keyword_set(dec)) then $
      vicsetpar, label, 'DEC', strtrim(string(dec, form='(d20.10)'),2)
 if(keyword_set(target)) then vicsetpar, label, 'TARGET', target

 write_vicar, filename, dat, label

end
;=============================================================================
