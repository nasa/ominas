;=============================================================================
;+
; NAME:
;	pnt_uncompress
;
;
; PURPOSE:
;	Explodes a compressed POINT object back into an array of POINT objects
;	using the original POINT objects as a template.  The 
;	compressed POINT object is freed.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	new_ptd = pnt_uncompress(pptd, ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	pptd:	Compressed POINT object.
;
;	ptd:	Array of original POINT objects to use as a template.  
;		Must be in the same order as when compressed.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nn:		If given, it is assumed that there are nn elements
;			in the compressed array for each element in the 
;			original input arrays. 
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array of POINT objects containing the uncompressed data.
;
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_uncompress
;	
;-
;=============================================================================
function pnt_uncompress, pptd, ptd0, nn=nn

 if(NOT keyword_set(nn)) then nn = 1 

 ;-------------------------------------------
 ; clone template
 ;-------------------------------------------
;;;; why not uncompress into original object?
 ptd = nv_clone(ptd0)


 ;-------------------------------------------
 ; get compressed arrays
 ;-------------------------------------------
 tags = pnt_tags(pptd)
 ndat = n_elements(tags)
 nptd = n_elements(ptd)
 np = pnt_nv(pptd)/nn

 pp = pnt_points(pptd)
 vv = pnt_vectors(pptd)
 ff = pnt_flags(pptd)
 data = pnt_data(pptd)
 name = cor_name(pptd)

 pp = reform(pp, 2,np,nn, /over)
 vv = reform(vv, np,3,nn, /over)
 ff = reform(ff, np,nn, /over)
 data = reform(data, ndat,np,nn, /over)


 ;--------------------------------
 ; uncompress arrays
 ;--------------------------------
 for i=(jj=0), nptd-1 do $
  begin
   nnp = pnt_nv(ptd[i])

   p = reform(pp[*,jj:jj+nnp-1,*], 2,nnp*nn)
   v = reform(vv[jj:jj+nnp-1,*,*], nnp*nn,3)
   f = reform(ff[jj:jj+nnp-1,*], nnp*nn)
   dat = reform(data[*,jj:jj+nnp-1,*], ndat,nnp*nn)
   pnt_assign, ptd[i], p=p, v=v, flags=f, name=nam, data=dat, tags=tags

   cor_set_udata, ptd[i], '', tag_list_clone(cor_udata(pptd))

   jj = jj + nnp
  end


 ;-------------------------------------------
 ; free compressed POINT object
 ;-------------------------------------------
 nv_free, pptd

 return, ptd
end
;=============================================================================




