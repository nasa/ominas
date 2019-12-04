;=============================================================================
;+
; NAME:
;	compute_segments
;
;
; PURPOSE:
;	Computes subscripts of segments in a continuous curve due to a subset of 
;	points being selected, or wrapping across an image.
;
;
; CATEGORY:
;	UTIL/
;
;
; CALLING SEQUENCE:
;	segments = compute_segments(p, subscripts)
;
;
; ARGUMENTS:
; 	p:		Array of image points.
;	
;	subscripts:	Subscripts of selected points.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array of structures, each giving the start and stop subscripts for a 
;	segment.  The jth segment is addressed as:
;
;		 segments[j].start:segments[j].stop
;
;	Output aubscripts are relative to the input array.
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2016
;	
;-
;=============================================================================
function compute_segments, p, _ii

 ii = _ii

 nii = n_elements(ii)
 if(nii LT 3) then return, {start:0, stop:n_elements(ii)-1}

 ;- - - - - - - - - - - - - - - - -
 ; find contiguous segments
 ;- - - - - - - - - - - - - - - - -
 ii0 = 0
 repeat $
  begin
   w = contiguous_indices(ii)
   nw = n_elements(w)

   segments = append_array(segments, {start:long(ii0), stop:long(ii0+nw-1)})
   ii0 = ii0 + nw

   if(nw NE n_elements(ii)) then ii = ii[nw:*] $
   else ii = -1
  endrep until(ii[0] EQ -1)
 nseg = n_elements(segments)

return, segments





 ;- - - - - - - - - - - - - - - - -
 ; find image wraps
 ;- - - - - - - - - - - - - - - - -
 for i=0, nseg-1 do $
  begin
   pp = p[*,segments[i].start:segments[i].stop]
   npp = n_elements(pp)/2
   dpp = total((pp[*,1:*] - pp[*,0:npp-2])^2, 1)

   w = where(dpp GE stdev(pp^2))
   nw = n_elements(w)
   if(w[0] NE -1) then $
    begin
     xx = append_array(xx, i+1)
     for j=0, nw do $
      begin
       start = 0l
       if(j GT 0) then start = long(w[j-1])+1
       stop = segments[i].stop
       if(j LT nw) then stop = long(w[j])

       segments = append_array(segments, $
              {start:segments[i].start+start, stop:segments[i].start+stop})
      end
    end
  end

 if(keyword_set(xx)) then $
  begin
   xx = xx - 1
   segments = rm_list_item(segments, xx)
  end


 return, segments
end
;===========================================================================



