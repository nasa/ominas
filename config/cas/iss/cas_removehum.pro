FUNCTION cas_removehum, noisyimg, mask=mask,  bpa=bpa,   oc=oc, ext=ext,  $
                fwidth=fwidth, dccoupled=dccoupled,  hum=hum
;
; Remove the 2Hz noise (aka "hum") from an image using signal extracted
; from background pixel values.
;
;
; INPUT:
;
;       noisyimg:  2D images (may be a layer of a 3D image stack)
;
;       mask (optional):  2D array indicating non-bkg pixels
;                      0= bgk,  1= object or noise pixel 
;                      mask = fattenmask(img, 5, thresh=51.0)
;                               if mask is given, will use image data.
;                               if bpa also given, uses overclocked only to fill
;                               in lines that lack enough bkg pixels.
;
;
;       fwidth:     sets width of stopband for the low-freq blocking filter
;                           value is spatial frequency - vertical cycles per image
;
;       /dccoupled (optional):  retain the DC and very low freq components
;                    default is to filter these out so that 
;                    dark current, bias etc can be studied
;                        or subtracted in separate steps.
;
; OUTPUT
;       
;       hum:   1D array providing the extracted 2hz hum signal as function of line number
;
;
; RETURNS
;
;   1D array of 2Hz noise signal as function of iamge line number
;
; CHANGES
;   2004-Feb-04 DSW: split multi-modal routine into separate scripts, easier to use
;   2004-Feb-03 DSW: added Extended Pixel mode
;   2003-Dec-11 DSW: added pre-smoothing, discovered to greatly enhance quality
;



img=reform(noisyimg)
w=(size(img))[1]
h=(size(img))[2]


ones=replicate(1, h)



; how to tell median to ignore masked pixels?
; do median of all pixels, but first replace masked pixels with avg 
; of bkg pixels of scan line.  this will have less perturbing effect than 
; leaving stars in place.
if keyword__set(mask) then begin
        nnn = total(1.0-mask, 1)
        avgbkg = total(img*(1.0-mask), 1) / (nnn > 1.0)
        tmpimg = mask*(ones#avgbkg) +  (1-mask)*img     
endif else begin
        tmpimg=img*1.0
endelse


; Extract hum signal by taking median across each row of a smoothed image,
; omit a strip along left & right due to dark edge in NAC and sometimes
; funny values in first or last column due to processing
; Presmoothing has been found to greatly improve the hum extraction,
; for reasons explained elsewhere.
;
if not keyword__set(skip_presmooth) then  begin
        tmpimg = smooth(tmpimg, 3, /edge)
endif



hum = median( 1.0*tmpimg[14:w-4,*], dimension=1)
sg=savgol(4,4,0,4)
hum = convol(hum, sg, /edge_t)


        
if not keyword__set(dccoupled)  then begin
        hum=cas_blocklowfreq(hum, fwidth=fwidth)
endif



return , img - ones # hum

END



