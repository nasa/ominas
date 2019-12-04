;============================================================================
; image_outline
;
;============================================================================
function image_outline, image, sample=sample, rectify=rectify

 im = byte(image<1)
 s = size(image)
 
 edge = (shift(im,1,0)-im) + $
        (shift(im,0,1)-im)


 w = where(edge GT 0)
 nw = n_elements(w)

 outline_pts = w_to_xy(im, w)

 if(keyword_set(rectify)) then outline_pts = poly_rectify(outline_pts)

;; if(keyword_set(sample)) then w = w[lindgen(nw/sample)*sample]

 return, outline_pts
end
;============================================================================
