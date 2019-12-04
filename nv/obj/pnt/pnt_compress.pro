;=============================================================================
;+
; NAME:
;	pnt_compress
;
;
; PURPOSE:
;	Compresses many POINT objects into one.  Arrays are concatenated
;	in the nv/np directions unless /nt is specified.  Point-by-point data
;	arrays must be identical.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	new_ptd = pnt_compress(ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:	Array of POINT objects.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nt:		If given, arrays are concatenated in the nt dimension.
;			this requires that all input arrays have the same number
;			of points (nv/np), and only one element in the nt 
;			direction.
;
;	nodata:		If set, point-by-pont data arrays are not included.
;
;	pptd:		If given, this points object is used to store the
;			result, rather than allocating a new one.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	POINT object containing the concatenated data.
;
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_compress
;	
;-
;=============================================================================
function pnt_compress, ptd0, nt=nt, pptd=pptd, nodata=nodata

 nodata = keyword_set(nodata)

 ;--------------------------------
 ; set up compressed arrays
 ;--------------------------------
 ptd = pnt_cull(ptd0, /nofree)				; remove null objects
 if(NOT keyword_set(ptd)) then return, obj_new()

 tags = pnt_tags(ptd[0])				; assume all data arrays identical
 ndat = n_elements(tags)
 nv0 = pnt_nv(ptd[0])
 nvv = pnt_nv(ptd)

 np = total(nvv)
 if(np EQ 0) then return, obj_new()

 nptd = n_elements(ptd)

 pp = dblarr(2,np)
 vv = dblarr(np,3)
 ff = bytarr(np)
 names = strarr(nptd)
 if(NOT nodata) then data = dblarr(ndat,np)


 ;--------------------------------
 ; compress arrays
 ;--------------------------------
 for i=(jj=0), nptd-1 do $
  begin
   pnt_query, ptd[i], points=p, vectors=v, flags=f, data=dat, name=nam, nv=nv

   if(nv GT 0) then $
    begin
     pp[*,jj:jj+nv-1] = p
     vv[jj:jj+nv-1,*] = v
     ff[jj:jj+nv-1] = f
     if(NOT nodata) then data[*,jj:jj+nv-1] = dat
     names[i] = nam
    end
  jj = jj + nv
  end
 name = str_comma_list(unique(names))

 if(keyword_set(nt)) then $
  begin
   pp = reform(pp, 2,nv0,nptd, /over)
   vv = reform(vv, nv0,3,nptd, /over)
   ff = reform(ff, nv0,nptd, /over)
   if(NOT nodata) then data = reform(data, ndat,nv0,nptd, /over)
  end


 ;-------------------------------------------
 ; create the compressed POINT object
 ;-------------------------------------------
 if(NOT arg_present(pptd)) then pptd = nv_clone(ptd[0])
 pnt_assign, pptd, points=pp, vectors=vv, flags=ff, data=data, name=name


 return, pptd[0]
end
;=============================================================================



