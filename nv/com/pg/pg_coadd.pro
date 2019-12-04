;=============================================================================
;+
; NAME:
;	pg_coadd
;
;
; PURPOSE:
;	Averages the given images and geometries. 
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	dd0 = pg_coadd(dd, bx0, cd=cd, bx=bx)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Array of data descriptors giving images to average.
;
;  OUTPUT: 
;	bx0:	Averaged bx body descriptors.
;
;
; KEYWORDS:
;  INPUT:
;	bx:	Array [ndd] or [ndd,n] of descriptors of any superclass of BODY,
;		one for each input image, to be averaged.  Times, positions, and
;		orientations are average.  In addition, for any camera
;		descriptors, the optical axes are also averaged.
;
;	gd:	Generic descriptor containing the body descriptors or an 
;		array [ndd] of generic descriptors.
;
;	median: If set, the median is used instead of the average.
;
;	minimum: If set, the minimum is used instead of the average.
;
;	maximum: If set, the maximum is used instead of the average.
;
;	algorithm: String giving the alogrithm to use instead of specifying
;		   One of the above keyowrds.  Default is 'average".
;
;  OUTPUT: NONE
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 4/2014
;	
;-
;=============================================================================



;=============================================================================
; pgc_compute_average
;
;=============================================================================
function pgc_compute_average, dd
 ndd = n_elements(dd)

 im0 = dblarr(dat_dim(dd[0]))
 for i=0, ndd-1 do im0 = im0 + dat_data(dd[i])
      
 return, im0/ndd
end
;=============================================================================



;=============================================================================
; pgc_compute_median
;
;=============================================================================
function pgc_compute_median, dd
 ndd = n_elements(dd)
 im = dblarr([dat_dim(dd[0]), ndd])

 for i=0, ndd-1 do im[*,*,i] = dat_data(dd[i])

 return, image_median(im)
end
;=============================================================================



;=============================================================================
; pgc_compute_minimum
;
;=============================================================================
function pgc_compute_minimum, dd
 ndd = n_elements(dd)

 im0 = dat_data(dd[0])
 for i=1, ndd-1 do im0 = im0 < dat_data(dd[i])
      
 return, im0
end
;=============================================================================



;=============================================================================
; pgc_compute_maximum
;
;=============================================================================
function pgc_compute_maximum, dd
 ndd = n_elements(dd)

 im0 = dat_data(dd[0])
 for i=1, ndd-1 do im0 = im0 > dat_data(dd[i])
      
 return, im0
end
;=============================================================================





;=============================================================================
; pg_coadd
;
;=============================================================================
function pg_coadd, dd, bx0, cd=cd, bx=bx, gd=gd, $
     median=median, minimum=minimum, maximum=maximum, algorithm=algorithm

 ndd = n_elements(dd)
 if(keyword_set(bx)) then n = n_elements(bx)/ndd

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(dd)) then dd = dat_gd(gd, /dd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)


 ;-----------------------------------------------
 ; compute new image
 ;-----------------------------------------------
 if(keyword_set(minimum)) then algorithm = 'minimum'
 if(keyword_set(maximum)) then algorithm = 'maximum'
 if(keyword_set(median)) then algorithm = 'median'

 if(keyword_set(algorithm)) then algorithm = strlowcase(algorithm) $
 else algorithm = 'average'

 fn = 'pgc_compute_' + algorithm
 im0 = call_function(fn, dd)


 ;-----------------------------------------------
 ; average descriptors
 ;-----------------------------------------------
 if(keyword_set(bx)) then $
  begin
   bx0 = objarr(n)
   bod_time0 = dblarr(n)
   bod_pos0 = dblarr(1,3,n)
   bod_orient0 = dblarr(3,3,n)
   cam_oaxis0 = dblarr(2,n)

   for j=0, n-1 do $
    begin
     bx0[j] = nv_clone(bx[0,j])
     bod_time0[j] = 0d
     bod_pos0[*,*,j] = dblarr(1,3)
     bod_orient0[*,*,j] = dblarr(3,3)
    end
  end

 for i=0, ndd-1 do $
  begin
   if(keyword_set(bx)) then $
    for j=0, n-1 do $
     begin
      bod_time0[j] = bod_time0[j] + bod_time(bx[i,j])
      bod_pos0[*,*,j] = bod_pos0[*,*,j] + bod_pos(bx[i,j])
      bod_orient0[*,*,j] = bod_orient0[*,*,j] + bod_orient(bx[i,j])
      if(cor_class(bx[i,j]) EQ 'CAMERA') then cam_oaxis0[*,j] = cam_oaxis0[*,j] + cam_oaxis(bx[i,j])
     end
  end


 if(keyword_set(bx)) then $
  begin
   bod_time0 = bod_time0 / ndd		& for j=0, n-1 do bod_set_time, bx0[j], bod_time0[j]
   bod_pos0 = bod_pos0 / ndd		& for j=0, n-1 do bod_set_pos, bx0[j], bod_pos0[*,*,j]
   bod_orient0 = bod_orient0 / ndd	& for j=0, n-1 do bod_set_orient, bx0[j], bod_orient0[*,*,j]
   cam_oaxis0 = cam_oaxis0 / ndd	& for j=0, n-1 do if(cor_class(bx0[j]) EQ 'CAMERA') then cam_set_oaxis, bx0[j], cam_oaxis0[*,j]
  end

 dd0 = nv_clone(dd[0])
 dat_set_data, dd0, im0



 return, dd0
end
;=============================================================================
