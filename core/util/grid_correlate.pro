;=============================================================================
;+
; grid_correlate
;
; PURPOSE :
;
;  Search for the vector offset, t, at which image2 best correlates with
; image1 (without searching the entire array).
;
;
;  The algorithm works as follows:
;
; 1) begin with a grid of size nsamples covering the entire image1,
;    for example, for nsample=[4,4], the grid might look like :
;                     
;            -------------------------
;           |   .     .     .     .   |
;           |                         |<-----image array
;           |                         |
;           |   .     .     .     .   |
;           |                         |
;           |                         |
;           |   .     .     .     .<--|---sample each of these offsets
;           |                         |
;           |                         |
;           |   .     .     .     .   |
;            -------------------------
;
; 2) evaluate the cross correlation function of image1 and image2
;     at each point on the grid and determine which point gave the
;     best result.  Store this point and its correlation in
;     best_arr.
;
; 3) center a new grid of the same configuration at that point
;     but make it smaller by grid_ratio : 
;                     
;            -------------------------
;        ---|---.   .   .   .     .   |
;         | |                         |<-----image array
;    new  | |   .   .   .   .         |
;    grid | |         +<----------.---|----best point from last scan
;         | |   .   .   .   .         |
;         | |                         |
;        ---|---.   .   .   .     .   |
;           |                         |
;           |                         |
;           |   .     .     .     .   |
;            -------------------------
;
; 4) continue until the entire grid becomes smaller than 1 pixel across.
;
; 5) return the point in best_arr which gave the best correlation.
;
; Accuracy:
;  The offset vector returned by this routine should usually
;   lie within one pixel of the actual maximum correlation.  The
;   result can only be guaranteed, though, if nsamples is set to the
;   size of the array, but this is almost never practical.
;
; Speed:
;  If you use nsamples of [2,2], the default, then each search cycle
;   will be as fast as possible, but it will take many cycles to converge 
;   on the maximum.  If you use a very fine grid, then it may take only
;   a few cycles, but the cycles will take very long.  Of course, 
;   generally one would expect it to be much faster to use a coarse grid
;   as opposed to one of the same size as the array, otherwise, there 
;   would have been no reason to write this program.  The total time
;   should scale as:
;
;         t = nsamples(0)*nsamples(1)  *  ncycles
;
;   where ncycles is the number of search cycles necessary to converge.
;   The exact value depends on the two images and their initial 
;   offsets.
;
;
; NOTE: Unless /nohome is set, the first point in best_arr always corresponds
;       to t=[0,0], i.e; no shift at all.  Thus, if the
;       images never needed to be shifted, then the result
;       the result will always be zero offset.
;
;
;
; CALLING SEQUENCE :
;
;   t=grid_correlate(im1, im2, correlation)
;
;
; ARGUMENTS
;  INPUT : im1 - reference image
;
;          im2 - image to be shifted
;
;  OUTPUT : correlation - cross correlation value after im2 has been
;                         shifted by t.
;
;
;
; KEYWORDS 
;  INPUT : show - Show the search.
;
;          nsamples - 2D vector giving the dimensions of the search grid,
;                     default is [2,2].
;
;          nohome - Do not check the offset [0,0] for best correlation.
;
;          function_min, function_max - Name of a function to either
;                                       minimize or maximize.  The
;                                       function should be declared as
;                                       follows:
;
;                                         function [name], f, g, t
;
;                                       and should return a number which
;                                       indicates the degree of correlation
;                                       between f ang g, with g shifted by t.
;
;          indices - This keyword will only work properly if both images
;                    are of the same dimensions.  It allows the caller
;                    to specify a region over which the correlation
;                    will be optomized by giving an array of the 1D subscripts
;                    which lie within that region.
;
;          kill_char - Key which can be used to abort the search and return
;                      an offset of [0,0], with the corresponding correlation.
;                      This slows down the loop a bit, but not significantly
;                      for large images, in which it may be more important
;                      for the user to be able to abort.
;
;	   region - Size of region to scan, centered at offset [0,0].  If not
;		    specified, the entire image is scanned.
;
;  OUTPUT : NONE
;
;
;
; RETURN : t, the vector offset by which im2 had to be shifted for 
;          maximum correlation with im1.
;
;
;
;
; KNOWN BUGS : see 'Accuracy' above.
;
;
;
; ORIGINAL AUTHOR : J. Spitale ; 8/94
;
; UPDATE HISTORY : Spitale, 4/2002 -- added 'region' keyword
;
;-
;=============================================================================


;=============================================================================
; ic_optimal
;
;=============================================================================
function ic_optimal, corr, data, minmax

 case minmax of
   'MAX' : return, corr GT max(data)
   'MIN' : return, corr LT min(data)
 endcase

end
;=============================================================================



;=============================================================================
; ic_get_correlation
;
;=============================================================================
function ic_get_correlation, fn, _image, _xx, t, corners=corners,  $
             norm=norm

 image = _image
 xx = _xx

 if(keyword_set(corners)) then $
  begin
   xmin=corners(0,0)<corners(0,1)
   xmax=corners(0,0)>corners(0,1)
   ymin=corners(1,0)<corners(1,1)
   ymax=corners(1,0)>corners(1,1)

   image=image(corners)
  end

 cc = call_function(fn, image, xx, t, norm=norm)

 return, cc
end
;=============================================================================



;=============================================================================
; ic_bias
;
;=============================================================================
function ic_bias, cc, t, bias, pixn

 dd2 = t[0]^2 + t[1]^2
 weight = exp(-dd2/(2d*bias))

 cc = cc*weight

 return, cc
end
;=============================================================================



;=============================================================================
; ic_reduce_t
;
;=============================================================================
function ic_reduce_t, nx, ny, t

 if(t[0] GT (nx-1)/2) then t[0] = t[0] - nx $
 else if(t[0] LT -(nx-1)/2) then t[0] = t[0] + nx

 if(t[1] GT (ny-1)/2) then t[1] = t[1] - ny $
 else if(t[1] LT -(ny-1)/2) then t[1] = t[1] + ny

 return, t
end
;=============================================================================



;=============================================================================
; ic_get_width
;
;=============================================================================
pro ic_get_width, data, tx, ty, scan_pix, nsamples, wx, wy 

 if(stdev(data) EQ 0) then return

 catch, err

 if(NOT keyword_set(err)) then $
  begin
   xx = gauss2dfit(data, coeff, tx[*,0], tr(ty[0,*]))     
   wx = wx < abs(coeff[2]*scan_pix[0]/nsamples[0])
   wy = wy < abs(coeff[3]*scan_pix[1]/nsamples[1])
  end


 catch, /cancel
end
;=============================================================================



;=============================================================================
; grid_correlate
;
;=============================================================================
function grid_correlate, image, xx, correlation, $
   show=show, nsamples=_nsamples, nohome=nohome, $
   function_min=function_min, function_max=function_max, $
   corners=corners, kill_char=kill_char, region=region, data=data, $
   wx=wx, wy=wy, no_width=no_width, bias=bias, fn_show=fn_show, $
   nosearch=nosearch

 ss = size(image)

 if(NOT keyword_set(_nsamples)) then _nsamples=[2,2]
 nsamples = _nsamples

 if(NOT keyword_set(function_min) AND NOT keyword_set(function_max)) then $
   function_max='cr_correlation'

 if(keyword_set(function_min)) then $
  begin
   fn=function_min
   minmax='MIN'
  end

 if(keyword_set(function_max)) then $
  begin
   fn=function_max
   minmax='MAX'
  end


 ;----------------------------------------
 ; search for best offset unless /nosearch
 ;----------------------------------------
 if(keyword_set(nosearch)) then t = [0d,0d] $
 else $
  begin


  ;-----------------set up initial grid-----------------

   grid_ratio=1.5
;   grid_ratio=2.5
   scan_cent_pix=[0e,0e]

   if(NOT keyword_set(region)) then $
    begin
     s=size(image)
     scan_pix=[s(1),s(2)]
    end $
   else scan_pix = region
 

  ;----------------set up best_arr---------------------

   corr_init = ic_get_correlation(fn, image, xx, [0,0], corners=corners)

   best_struct={bs, t    : [0e,0e], $
                  corr : corr_init  }
   best_arr=replicate(best_struct, 1)
   best_pix=best_struct


  ;-----------scan until oversampled in both directions---------

   first = 1
   wx = (wy = 5d)
   while((scan_pix[0] GE nsamples[0]) OR (scan_pix[1] GE nsamples[1])) do $
    begin
;     if(NOT first) then bias = 0 $
;     else first = 0

     nsamples[0] = nsamples[0] < scan_pix[0]
     nsamples[1] = nsamples[1] < scan_pix[1]

     data = dblarr(nsamples[0], nsamples[1])
     tx = dblarr(nsamples[0], nsamples[1])
     ty = dblarr(nsamples[0], nsamples[1])


     ;--------scan each grid------------------

     for j=0, nsamples(1)-1 do $
      for i=0, nsamples(0)-1 do $
       begin
        if(keyword_set(kill_char)) then $
         begin
          char = get_kbrd(0)
          if(char EQ kill_char) then $
           begin
            print, 'Aborted.'
            correlation=corr_init
            return, [0,0]
           end
         end

        t = scan_cent_pix - double(scan_pix)/2e + $
                               double([i,j])*scan_pix/(nsamples-1)
        corr = ic_get_correlation(fn, image, xx, t, corners=corners)
        if(keyword_set(bias)) then corr = ic_bias(corr, t, bias)
        data[i,j] = corr
        tx[i,j] = t[0]
        ty[i,j] = t[1]

        if(keyword_set(show)) then $
         begin
          if(keyword_set(fn_show)) then $
                          call_procedure, fn_show, image, xx, t, show $
          else $
           begin
tvscl, xx, t[0], t[1]
tvscl, image
;            imm = bytscl(image)+shift(bytscl(xx), t(0), t(1))
;            if(n_elements(show) EQ 1) then tvscl, imm $
;            else tvscl, congrid(imm, show[0], show[1]) 
           end
         end
       end



     ;----------update best_arr and set up new grid--------

      if(NOT keyword_set(no_width)) then $
                    ic_get_width, data, tx, ty, scan_pix, nsamples, wx, wy

      data_max = max(data)
      if(data_max GT best_pix.corr) then $
       begin
        best_pix.corr = max(data)
        w = (where(data EQ best_pix.corr))[0]
        if(w[0] NE -1) then $
         begin
          tt = [tx[w],ty[w]]
          best_pix.t = ic_reduce_t(ss[1], ss[2], tt) 

          best_arr = [best_arr,best_pix]
         end
       end

      scan_pix = double(scan_pix)/grid_ratio
      scan_cent_pix = best_pix.t
    end

   if(keyword_set(nohome)) then best_arr = best_arr[1:*]


  ;-------------find and return the best of the best points----------

   case minmax of
     'MAX' :  p = where(best_arr.corr EQ max(best_arr.corr))
     'MIN' :  p = where(best_arr.corr EQ min(best_arr.corr))
   endcase

   t = best_arr(p[0]).t

  end


 correlation = ic_get_correlation(fn, image, xx, t, corners=corners, /norm)

 return, t
end
;============================================================

