;=============================================================================
;+
; NAME:
;	pg_get_planets
;
;
; PURPOSE:
;	Obtains planet descriptors for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_planets(arg1, arg2, od=od)
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
;	pd:		Input planet descriptors; used by some translators.
;
;	od:		Observer descriptor, typically a camera descriptor.
;			If given, then planet positions will be corrected
;			for light travel time and stellar aberration relative
;			to this observer unless /raw is set.
;
;	sd:		Primary star descriptor; needed by some translators.
;
;	gd:		Generic descriptors.  Can be used in place of od and sd.
;
;	raw:		If set, no aberration corrections are performed.
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
;	PLANET Keywords
;	---------------
;	All PLANET override keywords are accepted.  See plt__keywords.include.  
;	If 'name' is specified, then only descriptors with those names are 
;	returned.
;
;	DATA Keywords
;	-------------
;	All DATA override keywords are accepted.  See dat__keywords.include.  
;
;	Descriptor Select Keywords
;	--------------------------
;	Descriptor select keywords are combined with OR logic.  They are 
;	implemented in this routine after the translators have been called, 
;	but they are also added to the translator keywords.  The purpose of 
;	sending then to the translators as well is to give the translators 
;	an opportunity to filter their outputs before potentially generating 
;	a huge array of descriptors that would mostly be filtered out by this 
;	routine.  Named bodies are exempted.  See pg_select_bodies for a 
;	description of the standard keywords. 
;
;  OUTPUT:
;	count:	Number of descriptors returned
;
;
; RETURN:
;	Array of planet descriptors, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a planet descriptor is created and initialized
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



;===========================================================================
; pggp_select_planets
;
;
;===========================================================================
pro pggp_select_planets, pd, od=od, name=name, _extra=keyvals

 ;------------------------------------------------------------------------
 ; standard body filters
 ;------------------------------------------------------------------------
 sel = pg_select_bodies(pd, od=od, prefix='plt', _extra=keyvals)

 ;------------------------------------------------------------------------
 ; implement any selections
 ;------------------------------------------------------------------------
 pg_cull_bodies, pd, sel, name=name


end
;===========================================================================



;===========================================================================
; pg_get_planets
;
;===========================================================================
function pg_get_planets, arg1, arg2, pd=_pd, od=od, sd=sd, _extra=keyvals, $
                   override=override, verbatim=verbatim, raw=raw, count=count, $
                   @plt__keywords_tree.include
                   @dat__keywords.include
                   @dat_trs_keywords_include.pro
                   end_keywords

 count = 0

 ;------------------------------------------------------------------------
 ; sort out arguments
 ;------------------------------------------------------------------------
 pg_sort_args, arg1, arg2, dd=dd, od=od, time=time, $
                          trs=trs, free=free, $
                          @dat__keywords_tree.include
                          end_keywords
 ndd = n_elements(dd)

 ;---------------------------------------------------------------------
 ; add selection keywords to translator keywords and filter out any
 ; prefixed keywords that don't apply
 ;---------------------------------------------------------------------
 if(keyword_set(keyvals)) then pg_add_selections, trs, keyvals, 'PLT'

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(sd)) then sd = dat_gd(gd, dd=dd, /sd)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)

 if(keyword_set(od)) then $
   if(n_elements(od) NE n_elements(dd)) then $
          nv_message, 'One observer descriptor required for each data descriptor'


 ;-------------------------------------------------------------------
 ; if /override, create descriptors without calling translators
 ;-------------------------------------------------------------------
 if(keyword_set(override)) then $
  begin
   n = n_elements(name)
   if(n EQ 0) then n = ndd

   if(keyword_set(dd)) then gd = cor_create_gd(dd, gd=gd, /array)
   pd = plt_create_descriptors(n, $
               @plt__keywords_tree.include
               end_keywords)

   if(keyword_set(free)) then nv_free, dd
  end $
 ;-------------------------------------------------------------------
 ; otherwise, get planet descriptors from the translators
 ;-------------------------------------------------------------------
 else $
  begin
   ;-----------------------------------------------
   ; call translators
   ;-----------------------------------------------
   pd = dat_get_value(dd, 'PLT_DESCRIPTORS', key1=od, key2=sd, key4=_pd, $
                                key7=time, key8=name, trs=trs, $
                                  @dat_trs_keywords_include.pro
                                  end_keywords)

   ;------------------------------------------------------------------------
   ; Free dd if pg_sort_args determined that it will not be used outside 
   ; this function.  Note that the object ID is not lost will still appear
   ; in the gd.
   ;------------------------------------------------------------------------
   if(keyword_set(free)) then nv_free, dd

   if(NOT keyword_set(pd)) then return, obj_new()
   n = n_elements(pd)

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
   if(keyword_set(name)) then $
    begin
     tr_names = cor_name(pd)
     sub = nwhere(strupcase(tr_names), strupcase(name))
     if(sub[0] EQ -1) then return, obj_new()
     if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
    end $
   else sub=lindgen(n)

   n = n_elements(sub)
   pd = pd[sub]

   ;-----------------------------------
   ; perform aberration corrections
   ;-----------------------------------
   if(keyword_set(od) AND (NOT keyword_set(raw))) then $
    for i=0, ndd-1 do $
     begin
      w = where(cor_gd(pd, /dd) EQ dd[i])
      if(w[0] NE -1) then abcorr, od[i], pd[w], c=const_get('c')
     end

   ;-------------------------------------------------------------------
   ; override the specified values (name cannot be overridden)
   ;-------------------------------------------------------------------
   if(defined(name)) then _name = name & name = !null
   if(defined(time)) then _time = time & time = !null
   plt_assign, pd, /noevent, $
                @plt__keywords_tree.include
                end_keywords
   if(defined(_name)) then name = _name
   if(defined(_time)) then time = _time
  end

 ;--------------------------------------------------------
 ; filter planets
 ;--------------------------------------------------------
 if(NOT keyword_set(pd)) then return, obj_new()
 if(keyword_set(keyvals)) then $
                pggp_select_planets, pd, od=od, name=name, _extra=keyvals
 if(NOT keyword_set(pd)) then return, obj_new()

 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if((obj_valid(dd))[0]) then dat_set_gd, dd, gd, pd=pd, od=od, sd=sd, /noevent
 dat_set_gd, pd, gd, od=od, sd=sd, /noevent

 count = n_elements(pd)
 return, pd
end
;===========================================================================





