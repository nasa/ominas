;=============================================================================
;+
; NAME:
;	pg_get_maps
;
;
; PURPOSE:
;	Obtains a map descriptor for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_maps(arg1, arg2)
;
;
; ARGUMENTS:
;  INPUT:
;	arg1:	Data descriptor or transient translator argument.  In the
;		latter case, a string containing keywords and values to be 
;		passed directly to the translators as if they appeared as 
;		arguments in the translators table.  Keywords passed using 
;		this mechanism take precedence over keywords appearing in 
;		the translators table.  If no data descriptor is given, 
;		one may be constructed using DATA keywords (see below).  The
;		newly created data descriptor is freed unless this argument
;		is an undefined named variable, in which case the new
;		descriptor is returned in this variable.
;
;	arg2:	Transient translator argument, if present.
;
;  OUTPUT: 
;	arg1:	If present and undefined, any newly created data descriptor 
;		is returnedin this argument. 
;
;
; KEYWORDS:
;  INPUT:
;	md:		Input map descriptors; used by some translators.
;
;	override:	Create a data descriptor and initilaize with the 
;			given values.  Translators will not be called.
;
;	verbatim:	If set, the descriptors requested using name
;			are returned in the order requested.  Otherwise, the 
;			order is determined by the translators.
;
;	tr_override:	String giving a comma-separated list of translators
;			to use instead of those in the translators table.  If
;			this keyword is specified, no translators from the 
;			table are called, but the translators keywords
;			from the table are still used.   
;
;
;	MAP Keywords
;	---------------
;	All MAP override keywords are accepted.  See map__keywords.include.  
;	If 'name' is specified, then only descriptors with those names are 
;	returned.
;
;	DATA Keywords
;	-------------
;	All DATA override keywords are accepted.  See dat__keywords.include.  
;
;  OUTPUT:
;	count:	Number of descriptors returned
;
;
; RETURN:
;	Array of map descriptors, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a map descriptor is created and initialized
;	using the specified values.  Otherwise, the descriptor is obtained
;	through the translators.  Note that if /override is not used,
;	values (except name) can still be overridden by specifying 
;	them as keyword parameters.  If name is specified, then
;	only descriptors corresponding to those names will be returned.
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	Modified:	Spitale, 8/2001
;	
;-
;=============================================================================
function pg_get_maps, arg1, arg2, md=_md, gbx=gbx, dkx=dkx, bx=bx, _extra=keyvals, $
                        override=override, verbatim=verbatim, count=count, $
                              @map__keywords_tree.include
                              @dat__keywords.include
                              @dat_trs_keywords_include.pro
                              end_keywords

 count = 0

 ;------------------------------------------------------------------------
 ; sort out arguments
 ;------------------------------------------------------------------------
 pg_sort_args, arg1, arg2, dd=dd, trs=trs, free=free, $
                          @dat__keywords.include
                          end_keywords

 ;---------------------------------------------------------------------
 ; add selection keywords to translator keywords and filter out any
 ; prefixed keywords that don't apply
 ;---------------------------------------------------------------------
 if(keyword_set(keyvals)) then pg_add_selections, trs, keyvals, 'MAP'

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)


 ;----------------------------------------------------------
 ; Determine body type, GLOBE or DISK.
 ;----------------------------------------------------------
 if(keyword__set(bx)) then $
  begin
   if(cor_isa(bx, 'GLOBE')) then gbx = bx
   if(cor_isa(bx, 'DISK')) then dkx = bx
  end

 ;----------------------------------------------------------
 ; Use globe radii for map reference radii.
 ;----------------------------------------------------------
 if(NOT keyword_set(radii)) then $ 
  if(keyword_set(gbx)) then radii = glb_radii(gbx)


 ;----------------------------------------------------------
 ; use disk eccentricities to compute map reference radii.
 ;----------------------------------------------------------
 if(keyword_set(dkx)) then $
  begin
   a = 0.5d*total((dsk_sma(dkx))[0,*])
   e = 0.5d*total((dsk_ecc(dkx))[0,*])
   radii = [a*(1d - e), a*(1d - e^2), 0d]
   bx = dkx
  end

 ;-------------------------------------------------------------------
 ; if /override, create descriptors without calling translators
 ;-------------------------------------------------------------------
 if(keyword_set(override)) then $
  begin
   n = n_elements(name)
   if(n EQ 0) then $
    begin
     n = 1
     name = cor_name(bx)
    end

   if(keyword_set(dd)) then gd = cor_create_gd(dd, gd=gd, /array)
   md = map_create_descriptors(n, $
                  @map__keywords_tree.include
                  end_keywords)

   if(keyword_set(free)) then nv_free, dd
  end $
 ;-------------------------------------------------------------------
 ; otherwise, get map descriptors from the translators
 ;-------------------------------------------------------------------
 else $
  begin
   md = dat_get_value(dd, 'MAP_DESCRIPTORS', key1=ods, key4=_md, key8=name, trs=trs, $
                              @dat_trs_keywords_include.pro
                              end_keywords)

   ;------------------------------------------------------------------------
   ; Free dd if pg_sort_args determined that it will not be used outside 
   ; this function.  Note that the object ID is not lost will still appear
   ; in the gd.
   ;------------------------------------------------------------------------
   if(keyword_set(free)) then nv_free, dd

;   if(NOT keyword__set(md)) then md=map_create_descriptors(1)
   if(NOT keyword__set(md)) then return, obj_new()

   n = n_elements(md)

   ;---------------------------------------------------
   ; If name given, determine subscripts such that
   ; only values of the named objects are returned.
   ;
   ; Note that each translator has this opportunity,
   ; but this code guarantees that it is done.
   ;
   ; If name is not given, then all descriptors
   ; will be returned.
   ;---------------------------------------------------
   if(keyword__set(name)) then $
    begin
     tr_names = cor_name(md)
     sub = nwhere(strupcase(tr_names), strupcase(name))
     if(sub[0] EQ -1) then return, obj_new()
     if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
    end $
   else sub=lindgen(n)

   n = n_elements(sub)
   md = md[sub]

   ;-------------------------------------------------------------------
   ; override the specified values (name cannot be overridden)
   ;-------------------------------------------------------------------
   if(defined(name)) then _name = name & name = !null
   map_assign, md, /noevent, $
                    @map__keywords_tree.include
                    end_keywords
    if(defined(_name)) then name = _name

  end


 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if((obj_valid(dd))[0]) then $
              dat_set_gd, dd, gd, md=md, gbx=gbx, dkx=dkx, bx=bx, /noevent
 dat_set_gd, md, gd, gbx=gbx, dkx=dkx, bx=bx, /noevent

 count = n_elements(md)
 return, md
end
;===========================================================================




