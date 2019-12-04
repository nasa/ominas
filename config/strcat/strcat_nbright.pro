; docformat = 'rst'
;+
; Retrieves n brightest stars from a set of magnitudes
; 
; :Params:
;    mags : type=fltarr
;       vector of star magnitudes
;    nbright : type=long
;       number of stars to return
;  
; :Returns:
;     Vector of magnitudes with length nbright
;     
; :Private:
;-
function strcat_nbright, mags, nbright

 n = n_elements(mags)

 if(n LT nbright) then return, lindgen(n)

 return, (sort(mags))[0:nbright-1]
end
