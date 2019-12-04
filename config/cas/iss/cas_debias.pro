;=============================================================================
;+
; NAME:
;	cas_debias
;
;
; PURPOSE:
;	To remove horizontal banding in Cassini images
;
;
; CATEGORY:
;	UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;	result = debias(image, label, bpa)
;
;
; ARGUMENTS:
;  INPUT:
;	image:	Image data
;
;	label:	Image label from read_vicar
;
;	bpa:    Binary prefix bytes from read_vicar
;
;  OUTPUT:
;	bias:	Bias calculated	
;
;
; KEYWORDS:
;  INPUT:
;	average: Use average of overclocked pixels
;
;
; RETURN:
;	Real image with horizontal banding mostly subtracted.
;
;
; PROCEDURE:
;	This routine applies a digital filter to the overclocked 
;	pixel value found in the Binary prefix array (bpa) and then
;	subtracts this from the image.
;
;
;
; STATUS:
;	xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	V. Haemmerle, 3/2000
;	
;-
;=============================================================================
function cas_debias, image, label, bpa, bias=bias, average=average

;---------------------------
; Extract overclocked pixels
;---------------------------
 format = vicgetpar(label,'FORMAT')
 sb=size(bpa)
 if(sb[0] NE 2 OR sb[1] NE 24) then $
   begin
    print, 'BPA data is not raw'
    return, 0
   end $
  else $
   begin
    overclock = bpa[23,*] 
    if(format eq 'HALF') then overclock = overclock + 256*bpa[22,*]
   end
  
;------------------------------------------
; Examine label to determine digital filter
;------------------------------------------
 compress = vicgetpar(label,'ENCODING_TYPE',status=status)
 if(size(status,/type) eq 7) then $
 compress = vicgetpar(label,'INST_CMPRS_TYPE')
 mode = vicgetpar(label,'INSTRUMENT_MODE_ID')
 convert = vicgetpar(label,'CONVERSION_TYPE',status=status)
 if(size(status,/type) eq 7) then $
 convert = vicgetpar(label,'DATA_CONVERSION_TYPE')
 if(compress EQ 'NOTCOMP' AND mode EQ 'FULL' AND convert EQ '12BIT') then $
   filter = digital_filter(0,0.3,50,20) $
  else filter = digital_filter(0,0.15,50,20)

;---------------------
; Create bias template
;---------------------
  if(convert EQ 'TABLE') then overclock = cas_reverse_lut(overclock)
; fix first two pixels if necessary
  if(overclock[0] GT 1.3*overclock[2]) then overclock[0] = overclock[2]
  if(overclock[0] LT 0.7*overclock[2]) then overclock[0] = overclock[2]
  if(overclock[1] GT 1.3*overclock[2]) then overclock[1] = overclock[2]
  if(overclock[1] LT 0.7*overclock[2]) then overclock[1] = overclock[2]
  result = moment(overclock)
  for i=3,n_elements(overclock)-2 do $
   begin
    if(overclock[i] GT 1.3*result[0]) then overclock[i] = ( overclock[i-1] + $
                                           overclock[i+1]) /2.
    if(overclock[i] LT 0.7*result[0]) then overclock[i] = ( overclock[i-1] + $
                                           overclock[i+1]) /2.
   end
  overclock = float(overclock)
  n_pixels = n_elements(overclock)
  overclock = reform(overclock, n_pixels, /overwrite)
  if(keyword__set(average)) then $
   begin
    ave = total(overclock)/n_pixels
    bias = [replicate(ave, n_pixels)]
   end $
  else $
   bias = convol(overclock, filter, /edge_truncate)

;--------------
; Subtract bias
;--------------
  si = size(image) 
  if(convert EQ 'TABLE') then $ 
    outimage = float(cas_reverse_lut(image)) $
  else outimage = float(image)
  for i=0,si[2]-1 do outimage[*,i] = outimage[*,i] - bias[i]
  subs = where(image EQ 0, count)
  if(count NE 0) then outimage[subs] = 0.  ;Rezero out zeros in original

  return, outimage

end
