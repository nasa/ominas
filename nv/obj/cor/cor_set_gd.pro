;=============================================================================
;+
; NAME:
;	cor_set_gd
;
;
; PURPOSE:
;	Sets the generic descriptor in a CORE object.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	cor_set_gd, crd, gd
;
;
; ARGUMENTS:
;  INPUT:
;	crd:		CORE object.  The fields from any existing generic 
;			descriptor in this object are retained in the new one.
;			Only one object allowed.
;
;	gd:		New gd.  If no other inputs are given, then the current
;			gd is overwritten with this one.  Otherwise, fields are
;			appended as specified.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<x>d:		Input keyword for each descriptor type.
;
;	xds:		Array of objects to put in generic descriptor.  Generic
;			descriptors in these objects are considered as well.
;
;	noevent:	If set, no event is generated.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	cor_gd
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro cor_set_gd, crd0, gd, xds=xds, noevent=noevent, _extra=gdx
@core.include

 if(NOT keyword_set(crd0)) then return

 _crd0 = cor_dereference(crd0)

 ;------------------------------------------------------------------
 ; If no descriptor keywords, and no xds given, then overwrite gd
 ;------------------------------------------------------------------
 if(keyword_set(gd) AND $
      NOT keyword_set(xds)AND $
           NOT keyword_set(gdx)) then _cor_set_gd, _crd0, gd $

 ;------------------------------------------------------------------
 ; otherwise, append inputs to existing gd
 ;------------------------------------------------------------------
 else $
  begin
   if(keyword_set(gd)) then xds = append_array(xds, cor_dereference_gd(gd))	;;;
   gd0 = _cor_gd(_crd0)

   new_gd = cor_create_gd(xds, gd=gd0, _extra=gdx)

   if(keyword_set(new_gd)) then _cor_set_gd, _crd0, new_gd
  end


 cor_rereference, crd0, _crd0
 nv_notify, crd0, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================



;=============================================================================
pro ___cor_set_gd, crd0, gd, xds=xds, noevent=noevent, _ref_extra=keys
@core.include
;;;; should this be _extra instead of _ref_extra?

 _crd0 = cor_dereference(crd0)
 n = n_elements(_crd0)

 ;------------------------------------------------------------------
 ; If no descriptor keywords, and no xds given, then overwrite gd
 ;------------------------------------------------------------------
 if(keyword_set(gd) AND $
      NOT keyword_set(xds)AND $
           NOT keyword_set(keys)) then _cor_set_gd, _crd0, gd $

 ;------------------------------------------------------------------
 ; otherwise, append inputs to existing gd
 ;------------------------------------------------------------------
 else $
  begin
   if(keyword_set(gd)) then xds = append_array(xds, cor_dereference_gd(gd))	;;;
   gd0 = _cor_gd(_crd0)

   new_gd = cor_create_gd(xds, gd=gd0, _extra=keys)

   if(keyword_set(new_gd)) then _cor_set_gd, _crd0, new_gd
  end

 cor_rereference, crd0, _crd0
 nv_notify, crd0, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================





