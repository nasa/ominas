FUNCTION cas_removehum_oc, noisyimg, bpa,  skip_presmooth=skip_presmooth,  $
                dccoupled=dccoupled,    hum=hum

; Remove the 2Hz Noise (aka "hum") from an image using overclocked pixel values
; Obtain OC values from the binary prefix, which you may obtain
; using OMINAS's read_vicar function, giving it the optional bpa argument
; 
; Example:
;
;       img = read_image('FantasticImageOfIapetus1234.IMG', label, bpa=bpa)
;       clean_img = cas_removehum_oc(img, bpa)
;
; INPUT
;
;       noisyimg:  image in 2D array 
;
;       bpa:     binaryprefix, a 2D array, 24 bytes by NL (image height)
;
;       /dccoupled  (optional):   includes subtraction of any low-freq and constant
;                       part of the 2Hz "signal", effectively removing bias and 
;                       horizontally averaged darkframe effects along with the 2Hz noise.
;
;       /skip_presmooth:   don't do any smoothing of the signal. Not recommended, 
;                since overclocked pixels are few and so OC data tends to be noisy.
;
;
; OUTPUT
;
;       hum:    a 1D array containing the extracted 2Hz signal as a function
;                       of line number (0 to 1023)
;
;

s=(size(bpa))[2]

img=reform(noisyimg)
w=(size(img))[1]
h=(size(img))[2]

if s ne h then begin
        print, 'Binary prefix array height ',  s,  $
                    ' differs from image height ', h, '- cannot proceed'
        print, 'Did you supply the bpa arg to cas_removehum_oc?'
        hum=0
        return ,noisyimg
end



case h of
        1024: begin
                        nfirst=2.    ; use floating point to avoid integer division
                        nlast=6.
                        end
        512: begin
                        nfirst=1.
                        nlast=3.
                        end
        256: begin
                        nfirst=1.
                        nlast=1.
                        end             
endcase

nall = nfirst+nlast
                

foc = reform(256.*bpa[12,*]+1.0*bpa[13,*])
loc = reform(256.*bpa[22,*]+1.0*bpa[23,*])
hum = (foc + loc)*1.0/nall
if not keyword__set(skip_presmooth) then begin
  hum =smooth(hum, 3, /edge)
  sg=savgol(3,3,0,2)
  hum=convol(hum, sg, /edge_t)
endif

if not keyword__set(dccoupled)  then begin
        hum=cas_blocklowfreq(hum, fwidth=fwidth)
endif


ones=replicate(1, h)
return , img - ones # hum

END

