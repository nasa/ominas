;=============================================================================
;+
; NAME:
;	cor_gd
;
;
; PURPOSE:
;	Returns the generic descriptor for a CORE object.
;
;
; CATEGORY:
;	NV/PGS
;
;
; CALLING SEQUENCE:
;	gd = cor_gd(crd)
;
;
; ARGUMENTS:
;  INPUT:
;	crd:	Subclass of CORE.  Multiple descriptors may be given,
;		but an error will result if their generic descriptors
;		are incompatible.
;
;	name:	If given, only descriptors whose names appear in this array
;		will be returned.  If no descriptor keywords are
;		specified (see below), then all fields are searched for
;		descriptors with these names.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<x>d:	Standard descriptor keywords.  Setting a keyword causes 
;		the corresponding field of the generic descriptor to be 
;		returned instead of the generic descriptor.  
;
;	nocull: If set, a retuned array of descriptors will contain null
;		objects corresponding to inputs that contain no generic
;		descriptors.
;
;	noevent:
;		If set, no event is generated.
;
;  OUTPUT: NONE
;
;
;
; RETURN: 
;	Generic descriptor. 
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
function cor_gd, crd0, name=name, nocull=nocull, noevent=noevent, _ref_extra=keys

 if(NOT keyword_set(crd0)) then return, !null
 n = n_elements(crd0)

 nv_notify, crd0, type = 1, noevent=noevent
 _crd0 = cor_dereference(crd0)


 ;------------------------------------------------------------------
 ; If no descriptor keywords, and no names given, then output gd(s)
 ;------------------------------------------------------------------
 if((NOT keyword_set(keys)) AND (NOT keyword_set(name))) then $
  begin
   for i=0, n-1 do gd = append_array(gd, _cor_gd(_crd0[i]))
   return, gd
  end


 ;------------------------------------------------------------------
 ; otherwise, output the requested xds
 ;------------------------------------------------------------------
 for i=0, n-1 do $
  begin
   gd = _cor_gd(_crd0[i])
   if(NOT keyword_set(gd)) AND (keyword_set(nocull)) then $
                                        xds = append_array(xds, obj_new(), /def) $
   else xds = append_array(xds, cor_dereference_gd(gd, name=name, _extra=keys))
  end

 return, xds
end
;===========================================================================
