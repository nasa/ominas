;=============================================================================
;+
; NAME:
;	cas_desky
;
;
; PURPOSE:
;	To remove horizontal banding in Cassini images by removing
;	the background which includes the bias and dark current
;
;
; CATEGORY:
;	UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;	result = cas_desky(image, sample)
;
;
; ARGUMENTS:
;  INPUT:
;	image:	Image data
;
;	sample: Array of sample segments [start_x1, end_x1, start_x2, ...]
;
;  OUTPUT:
;	NONE
;
; KEYWORDS:
;  INPUT:
;	tol:	DN tolerance around median to include in average
;
;	maxsig:	Sigma tolerance above mean to include in average
;
;	width:	If set, median is done using a box this size rather
;		than across lines
;
;      smooth:  Smooth the calculated result vertically using this
;	        number of pixels (should be odd number)
;
;	 skip:  If specified, will skip the before and after pixel
;	        of pixels that are thrown out.  /skip does not work
;	        when using width.
;
; RETURN:
;	Real image with horizontal banding, bias and DC mostly subtracted.
;
;
; PROCEDURE:
;	This routine calculates an average background to subtract by
;	median filtering (or sigma filtering) and averaging the image between
;	the given sample ranges.  The averaging is done in the sample direction 
;	because both the horizontal banding and the dark current is nearly
;	constant along this direction.  The area selection should be almost all
;	sky for a reasonable result.  This routine may not work well in images
;	with strong gradiants.
;
;
; STATUS:
;	Tweeks still being applied.
;
;
; MODIFICATION HISTORY:
; 	Written by:	V. Haemmerle, 3/2000
;	Modified by:    V. Haemmerle, 1/2001
;	
;-
;=============================================================================
function cas_desky, image, sample, tol=tol, maxsig=maxsig, width=width, $
                               skip=skip, smooth=smooth

 si = size(image)
 if(si[0] NE 2) then $
  begin
   print,'Desky - Image is not 2-dimensional array: No processing done'
   return, image
  end

;-------------------
; Check sample array
;-------------------
 n_segments = n_elements(sample)/2
 if(min(sample) LT 0) then $
  begin
   print,'Desky - Sample element lower than image bound: No processing done'
   return, image
  end
 if(max(sample) GE si[1]) then $
  begin
   print,'Desky - Sample element higher than image bound: No processing done'
   return, image
  end
 if(n_elements(sample) NE 2*n_segments) then $
  begin
    print,'Desky - Sample array not in start/end format: No processing done'
    return, image
  end
 for i = 0, n_segments-1 do $
  begin
   if(sample[2*i+1] LT sample[2*i]) then $
    begin
     print,'Desky - Sample array has mismatch of start/end: No processing done'
     return, image
    end
  end

;---------------------
; Extract image swath
;---------------------
 bsize = 0
 for i = 0, n_segments-1 do bsize = bsize + sample[2*i+1] - sample[2*i] + 1
 swath = fltarr(bsize,si[2])
 xstart = 0
 for i = 0, n_segments-1 do $
  begin
    xend = xstart + sample[2*i+1] - sample[2*i]
    swath[xstart:xend,*] = float(image[sample[2*i]:sample[2*i+1],*])
    xstart = xend + 1
  end

;----------------------
; Remove non-sky pixels
;----------------------
 if(keyword__set(tol) AND keyword__set(maxsig)) then $
  begin
    print,'Desky - Cannot specify both tol and maxsig: No processing done'
    return, image
  end 

; skymom = moment(swath,sdev=sigma,/double)
; subs = where(swath GT skymom[0]+5.*sigma, count)
; print,'Desky - ',count,' full-frame 5-sigma pixels removed, sigma=',sigma
; if(count GT 0) then swath[subs] = 0

 if(keyword__set(maxsig)) then $
  begin
   for i = 0, si[2]-1 do $
    begin
      line = swath[*,i]
      subs = where(line NE 0, count)
      line = line[subs]
      skymom = moment(line,sdev=sigma,/double)
      subs = where(swath[*,i] GT skymom[0]+maxsig*sigma, count)
      if(count NE 0) then $
        begin
          swath[subs+bsize*i] = 0
          subs_legal = where(subs GT 0 AND subs LT si[2]-1)
          subs = subs[subs_legal]
          if(keyword__set(skip) and subs[0] NE -1) then $
            begin
              swath[subs+1+bsize*i] = 0
              swath[subs-1+bsize*i] = 0
            end
        end
    end
  end $
 else $
  begin
   _tol = 3
   if(keyword__set(tol)) then _tol = tol
   if(keyword__set(width)) then $
    begin
      med = median(swath,width)
      subs = where(abs(swath-med) GT _tol, count) 
      if(count NE 0) then swath[subs] = 0
    end $
   else $
    begin 
     for i = 0, si[2]-1 do $
      begin
        line = swath[*,i]
        subs = where(line NE 0, count)
        line = line[subs]
        med = median(line)
        subs = where(abs(swath[*,i]-med) GT _tol, count)
        if(count NE 0) then $
          begin
            swath[subs+bsize*i] = 0
            subs_legal = where(subs GT 0 AND subs LT si[2]-1)
            subs = subs[subs_legal]
            if(keyword__set(skip) and subs[0] NE -1) then $
              begin
                swath[subs+1+bsize*i] = 0
                swath[subs-1+bsize*i] = 0
              end
          end
      end
    end
  end
 
;-----------------------
; Calculate average bias
;-----------------------
 missing = 0
 bias = fltarr(si[2])
 for i = 0, si[2]-1 do $
  begin
   dummy = where(swath[*,i] NE 0, count) 
   if(count EQ 0) then missing = 1
   bias[i] = float(total(swath[*,i]))/float(max([count,1]))
  end
 if(keyword__set(smooth)) then bias = smooth(bias,smooth)
 if(missing EQ 1) then message, /continue, 'No background for some lines'

;--------------
; Subtract bias
;--------------
 outimage = fltarr(si[1],si[2])
 for i = 0, si[2]-1 do outimage[*,i] = float(image[*,i]) - bias[i]
 subs = where(image EQ 0, count)
 if(count NE 0) then outimage[subs] = 0  ;Rezero out zeros in original

 return, outimage

end
