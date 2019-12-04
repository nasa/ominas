;=============================================================================
;+
; NAME:
;	pnt_explode
;
;
; PURPOSE:
;	Explodes a POINT object into single-point objects.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	xptd = pnt_explode(ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	n:	If given, new objects will have nv = n instead of nv = 1.
;		nv must be divisible by n.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (nv/n x nt) of POINT objects, each containing a n points.
;
;
; STATUS:
;	Complete
;
;
;
;
; MODIFICATION HISTORY:
; 	Adapted from pgs_explode:	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_explode, ptd, n=n

 if(NOT keyword_set(n)) then n = 1
 n = long(n)

 pnt_query, ptd, nv=nv, nt=nt, $
        name=name, desc=desc, assoc_xd=assoc_xd, $
        flags=flags, points=points, vectors=vectors, data=data, tags=tags

 nvv = nv/n
 pptd = objarr(nvv, nt)

 for i=0, nvv-1 do $
  begin
   ii = lindgen(n)+i*n
   for j=0, nt-1 do $
    begin
     pptd[i,j] = nv_clone(ptd)

     pnt_set_flags, pptd[i,j], flags[ii,j], /noevent
     if(keyword_set(points)) then pnt_set_points, pptd[i,j], points[*,ii,j], /noevent
     if(keyword_set(vectors)) then pnt_set_vectors, pptd[i,j], vectors[ii,*,j], /noevent
     if(keyword_set(data)) then pnt_set_data, pptd[i,j], data[*,ii,j], /noevent

     cor_set_udata, pptd[i,j], '', tag_list_clone(cor_udata(ptd))
    end
  end

 return, pptd
end
;==============================================================================



;=============================================================================
; Alternative form that operates on the structures directly.  Much faster,
; but pointers get copied instead of cloned, so returned descriptors
; will share (for example) user data pointers.  Cloning all of the pointers
; makes this is slow as the other form.
;
;=============================================================================
function __pnt_explode, ptd, n=n

 if(NOT keyword_set(n)) then n = 1
 n = long(n)

 pnt_query, ptd, nv=nv, nt=nt, $
        name=name, desc=desc, assoc_xd=assoc_xd, $
        flags=flags, points=points, vectors=vectors, data=data, tags=tags

 nvv = nv/n
 _ptd = cor_dereference(ptd)
 _pptd = replicate(_ptd, nvv, nt)

 for i=0, nvv-1 do $
  begin
   ii = lindgen(n)+i*n
   for j=0, nt-1 do $
    begin
     _pptd[i,j].flags_p = nv_ptr_new(flags[ii,j])
     if(keyword_set(points)) then _pptd[i,j].points_p = nv_ptr_new(points[*,ii,j])
     if(keyword_set(vectors)) then _pptd[i,j].vectors_p = nv_ptr_new(vectors[ii,*,j])
     if(keyword_set(data)) then _pptd[i,j].data_p = nv_ptr_new(data[*,ii,j])

;;;;     cor_set_udata, pptd[i,j], '', tag_list_clone(cor_udata(ptd))
    end
  end

 pptd = pnt_create_descriptors(nvv)
 cor_rereference, pptd, _pptd
;;;for ... cor_set_udata, pptd, '', tag_list_clone(cor_udata(ptd))

 return, pptd
end
;==============================================================================



