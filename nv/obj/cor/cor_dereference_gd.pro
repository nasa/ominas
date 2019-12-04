;=============================================================================
;+
; NAME:
;	cor_dereference_gd
;
;
; PURPOSE:
;	Dereferences a generic descriptor.
;
;
; CATEGORY:
;	NV/PGS
;
;
; CALLING SEQUENCE:
;	xds = cor_dereference_gd(gd, <descriptor output keywords>)
;
;
; ARGUMENTS:
;  INPUT:
;	gd:	 Generic descriptor or object containing a generic descriptor.
;
;	name:	 If given, only descriptors whose names appear in this array
;		 will be returned.  If no descriptor keywords are
;		 speciied (see below), then all fields are searched for
;		 descriptors with these names.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<x>d:	 Standard descriptor keywords.  Setting a keyword causes the
;		 corresponding field of the generic descriptor to be returned.
;
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array of descriptors or zero if no fields found.  If no keywords
;	are given, then all descriptors are returned.
;
;
;
; MODIFICATION HISTORY:
;	Moved to CORE	Spitale		2/2017
;	
;-
;=============================================================================
function cor_dereference_gd, arg, name=name, _ref_extra=keys

 if(NOT keyword_set(arg)) then return, !null
 if(obj_valid(arg[0])) then gd = cor_gd(arg) $
 else gd = arg
 if(NOT keyword_set(gd)) then return, !null

 xds = !null

 ;--------------------------------------
 ; if no keywords, just return all xds
 ;--------------------------------------
 if((NOT keyword_set(name)) AND (NOT keyword_set(keys))) then $
  begin
   for j=0, n_elements(gd)-1 do $
    begin
     tags = tag_names(gd[j])
     ntags = n_elements(tags)

     for i=0, ntags-1 do $
             if(keyword_set(gd[j].(i))) then xds = append_array(xds, gd[j].(i))
    end
   return, xds
  end


 ;-----------------------------------
 ; build output list
 ;-----------------------------------
 gdtags = tag_names(gd)
 nkeys = n_elements(keys)

 for i=0, nkeys-1 do $
  begin
   w = where(gdtags EQ keys[i])
   if(w[0] NE -1) then xds = append_array(xds, gd.(w[0]))
  end


 ;-----------------------------------
 ; filter output list
 ;-----------------------------------
 if(keyword_set(name)) then $
  begin
   if(NOT keyword_set(keys)) then xds = cor_dereference_gd(gd)

   w = nwhere(cor_name(xds), name)
   if(w[0] EQ -1) then return, !null
   xds = unique(xds[w])
  end

 return, xds
end
;===========================================================================
