FUNCTION cas_blocklowfreq, humin,                  $
                fwidth=fwidth, order=order,             $
                tf=tf
                
; Suppress DC and low freq components of a 1D signal
; Intended for 2Hz noise removal.
; Vital if we want to retain low wavenumber variations
; for dark current analysis later.  Extracted dark frames
; should not contain 2Hz noise.  
;
; INPUT
;       hum:  1D array of 2Hz noise as function of image line number
;
;       fwidth (optional): filter cutoff freq in  cycles/image height
;
;       order (optional): order (pole count) of filter
;
;
; OUTPUTS
;
;       tf (optional):  freq-domain transer function
;                       Has same height as image, with f=0 located at center
;                       The 0th and last elements correspond to Nyquist freq.
;
;
; RETURNS
;               the hum signal with the DC/lowfreq part removed
;
;       
;
; DESIGN NOTES:
;
; Filter kernel was based loosely on a butterworth design,
; The 2Hz noise has typically 20-50 cycles per frame (vertical)
; so passband is flat and 100% from about k=15 up,  zero response at k=0,
; very low response for few-cycle per image height, smooth transition to 
; prevent ringing, 
; phase shift characteristics seem to be unimiportant in the transition zone.   
; but we do want zero phase shift in passband for accurate 2Hz noise modelling.
; 6th order seems to do very well at separating dark current from 2Hz hum.
; Call the result "AC Hum" as if we were EEs designing audio stuff.
;
if n_elements(fwidth) eq 0 then  fwidth = 10.0
if n_elements(order) eq 0 then order = 12
hum=reform(humin)
h= (size(hum))[1]  ; height of image

xhum = fltarr(h+h)   ; extended hum signal to impose good boundary conditions
xhum[0:h-1] = hum
xhum[h:2*h-1] = reverse(hum)

; Take Fourier of our 2Hz hum (including bias, dark current etc)
fhum=shift(fft(xhum), h)

; Create filter kernel in frequency space
; note use of "2.0D" for double IEEE to avoid overflow complaints
iii=1.0*indgen(h+h)

tf=  1.0 -  1.0/ sqrt((1.0 + ( (iii-(h/1.0D0)) / (2*fwidth) < 100.) ^ (2*order))  )

; Apply filter and de-Fourier signal 
fhum = fhum * tf
ac = float(fft( shift(fhum,h), /inverse))

; float() returns the real part of a complex number

return, ac[0:h-1]
END




