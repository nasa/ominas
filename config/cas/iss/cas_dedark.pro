;=============================================================================
;+
; NAME:
;	cas_dedark
;
;
; PURPOSE:
;	To remove horizontal banding and dark current in Cassini images
;
;
; CATEGORY:
;	UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;	result = cas_dedark(image, label, bpa)
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
;	bias:	Bias/dark calculated	
;
;
;
; RETURN:
;	Real image with horizontal banding mostly subtracted.
;
;
; PROCEDURE:
;	This routine applies a digital filter to the extended
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
function cas_dedark, image, label, bpa, bias=bias

;------------------------
; Extract extended pixels
;------------------------
 format = vicgetpar(label,'FORMAT')
 sb=size(bpa)
 if(sb[0] NE 2 OR sb[1] NE 24) then $
   begin
    print, 'BPA data is not raw'
    return, 0
   end $
  else $
   begin
    extended = bpa[21,*] 
    if(format eq 'HALF') then extended = extended + 256*bpa[20,*]
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
  if(convert EQ 'TABLE') then extended = cas_reverse_lut(extended)
  if(extended[0] GT 2*extended[1]) then extended[0] = extended[1]
  extended = float(extended)
  n_pixels = n_elements(extended)
  extended = reform(extended, n_pixels, /overwrite)
  bias = convol(extended, filter, /edge_truncate)

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
