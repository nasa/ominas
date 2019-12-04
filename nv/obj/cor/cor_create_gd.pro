;=============================================================================
;+
; NAME:
;	cor_create_gd
;
;
; PURPOSE:
;	Creates a generic descriptor from a set of given descriptors.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	new_gd = cor_create_gd(xds, gd=gd, <descriptor output keywords>
;
;
; ARGUMENTS:
;  INPUT: 
;	xds:	Array of descriptors.  If given, any generic descriptors 
;		contained within these descriptors are also included (unless 
;		/explicit).  A generic descriptor may also be given as the
;		argument to this function.  The field names for these inputs
;		is taken from their class. 
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	gd:	Generic descriptor.  Fields from this descriptor will be
;		included in the output.  The field names for these inputs are
;		preserved.
;
;	<x>d:	Input keyword for each descriptor type to include in 
;		new generic descriptor.  The field names for these inputs are
;		taken from the keyword name used.
;
;	explicit:
;		If set, generic descriptors contained in input descriptors
;		are not included in the output.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Generic descriptor containing all of the input fields, and any 
;	descripors contained in gd.  Any invalid objects are culled out.
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		
;	Moved to CORE	Spitale		2/2017
;	
;-
;=============================================================================



;=============================================================================
; ccgd_tag_names
;
;=============================================================================
function ccgd_tag_names, gd

 if(NOT keyword_set(gd)) then return, 0

 tags = tag_names(gd)
 for i=0, n_elements(tags)-1 do $
   if(keyword_set(gd.(i))) then $
            all_tags = append_array(all_tags, $
                              make_array(n_elements(gd.(i)), val=tags[i]))

 return, all_tags
end
;=============================================================================



;=============================================================================
; ccgd_append
;
;=============================================================================
function ccgd_append, gd

 ;------------------------------------------------------
 ; add explicit objects
 ;------------------------------------------------------
 xds = append_array(xds, cor_dereference_gd(gd))
 if(NOT keyword_set(xds)) then return, !null

 ;------------------------------------------------------
 ; cull out dead objects
 ;------------------------------------------------------
 w = where(obj_valid(xds))
 if(w[0] EQ -1) then return, !null
 xds = xds[w]

 ;------------------------------------------------
 ; put all xds into a new generic descriptor
 ;------------------------------------------------
 all_tags = cor_tag(xds)
 tags = unique(all_tags)
 for i=0, n_elements(tags)-1 do $
  begin
   w = where(all_tags EQ tags[i])
   ww = where(obj_valid(xds[w]))
   new_gd = append_struct(new_gd, create_struct(tags[i], unique(xds[w[ww]])))
  end

 return, new_gd


end
;=============================================================================



;=============================================================================
; cor_create_gd
;
;=============================================================================
function cor_create_gd, _xds, gd=_gd, explicit=explicit, array=array, _extra=gdx

 if(keyword_set(_gd)) then gd = _gd
 if(keyword_set(_xds)) then xds = _xds

 ;------------------------------------------------------
 ; test whether gd given as argument instead of xds 
 ;------------------------------------------------------
 if((NOT keyword_set(gd)) AND keyword_set(xds)) then $
  if(NOT cor_test(xds)) then $
   begin
    gd = xds
    xds = !null
   end

 ;------------------------------------------------------
 ; get objects from implicit gds
 ;------------------------------------------------------
 if(NOT keyword_set(explicit)) then $
            for i=0, n_elements(xds)-1 do $
                     xds = append_array(xds, cor_dereference_gd(cor_gd(xds[i])))
 xds = cor_cull(xds)
 all_tags = cor_tag(xds)

 ;------------------------------------------------------
 ; add explicit objects
 ;------------------------------------------------------
 xds = append_array(xds, cor_dereference_gd(gd))
 all_tags = append_array(all_tags, ccgd_tag_names(gd))

 xds = append_array(xds, cor_dereference_gd(gdx))
 all_tags = append_array(all_tags, ccgd_tag_names(gdx))

 if(NOT keyword_set(xds)) then return, !null

 ;------------------------------------------------------
 ; cull out dead objects
 ;------------------------------------------------------
 w = where(obj_valid(xds))
 if(w[0] EQ -1) then return, !null
 xds = xds[w]
 all_tags = all_tags[w]

 ;------------------------------------------------
 ; put all xds into a new generic descriptor
 ;------------------------------------------------
 tags = unique(all_tags)
 for i=0, n_elements(tags)-1 do $
  begin
   w = where(all_tags EQ tags[i])
   if(NOT keyword_set(array)) then $ 
         new_gd = append_struct(new_gd, create_struct(tags[i], unique(xds[w]))) $
   else for j=0, n_elements(w)-1 do $
      new_gd = append_array(new_gd, create_struct(tags[i], unique(xds[w[j]])))
  end

 return, new_gd
end
;=============================================================================







;=============================================================================
; cor_create_gd
;
;=============================================================================
function __cor_create_gd, _xds, gd=_gd, explicit=explicit, _extra=gdx

 if(keyword_set(_gd)) then gd = _gd
 if(keyword_set(_xds)) then xds = _xds

 ;------------------------------------------------------
 ; test whether gd given as argument instead of xds 
 ;------------------------------------------------------
 if((NOT keyword_set(gd)) AND keyword_set(xds)) then $
  if(NOT cor_test(xds)) then $
   begin
    gd = xds
    xds = !null
   end

 ;------------------------------------------------------
 ; get objects from implicit gds
 ;------------------------------------------------------
 if(NOT keyword_set(explicit)) then $
            for i=0, n_elements(xds)-1 do $
                     xds = append_array(xds, cor_dereference_gd(cor_gd(xds[i])))

 ;------------------------------------------------------
 ; add explicit objects
 ;------------------------------------------------------
 xds = append_array(xds, cor_dereference_gd(gd))
 xds = append_array(xds, cor_dereference_gd(gdx))
 if(NOT keyword_set(xds)) then return, !null

 ;------------------------------------------------------
 ; cull out dead objects
 ;------------------------------------------------------
 w = where(obj_valid(xds))
 if(w[0] EQ -1) then return, !null
 xds = xds[w]

 ;------------------------------------------------
 ; put all xds into a new generic descriptor
 ;------------------------------------------------
 all_tags = cor_tag(xds)
 tags = unique(all_tags)
 for i=0, n_elements(tags)-1 do $
  begin
   w = where(all_tags EQ tags[i])
   ww = where(obj_valid(xds[w]))
   new_gd = append_struct(new_gd, create_struct(tags[i], unique(xds[w[ww]])))
  end

 return, new_gd
end
;=============================================================================



