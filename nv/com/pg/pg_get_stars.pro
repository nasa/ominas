;=============================================================================
;+
; NAME:
;	pg_get_stars
;
;
; PURPOSE:
;	Obtain star descriptors for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_stars(arg1, arg2)
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
;	sd:		Input star descriptors; used by some translators.
;
;	od:		Observer descriptor, typically a camera descriptor.
;			If given, then star positions will be corrected
;			for stellar aberration (but not light-travel time,
;			which is inherently accounted for in star catalogs) 
;			relative to this observer, unless /raw is set.  
;
;	gd:		Generic descriptors.  Can be used in place of od.
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
;	STAR Keywords
;	---------------
;	All STAR override keywords are accepted.  See str__keywords.include.
;	If 'name' is specified, then only descriptors with those names are 
;	returned.
;
;	DATA Keywords
;	-------------
;	All DATA override keywords are accepted.  See dat__keywords.include.  
;
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
;	description of the standard keywords.  Additional keywords specific 
;	to this program are as follows:
;
;	  faint:	Select stars with magnitudes less than or equal to
;			this value.
;
;	  bright:	Select stars with magnitudes greater than or equal to
;			this value.
;
;	  nbright:	Select this many brightest stars.
;
;  OUTPUT:
;	count:	Number of descriptors returned
;
;
; RETURN:
;	Star descriptors obtained from the translators, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a star descriptor is created and initialized
;	using the specified values.  Otherwise, the descriptor is obtained
;	through the translators.  Note that if /override is not used,
;	values (except name) can still be overridden by specifying 
;	them as keyword parameters.  If name is specified, then
;	only descriptors corresponding to those names will be returned.
;	
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	Modified:	Spitale, 8/2001
;	
;-
;=============================================================================



;===========================================================================
; pggs_select_stars
;
;
;===========================================================================
pro pggs_select_stars, sd, od=od, name=name, _extra=keyvals

 ;------------------------------------------------------------------------
 ; standard body filters
 ;------------------------------------------------------------------------
 sel = pg_select_bodies(sd, od=od, prefix='str', _extra=keyvals)

 ;------------------------------------------------------------------------
 ; filters specific to stars
 ;------------------------------------------------------------------------
 n = n_elements(sd)
 mag = str_get_mag(sd)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 ; faint -- faintest magnitude to select
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 faint = extra_value(keyvals, 'faint', 'str')
 if(keyword_set(faint)) then $
  begin
   w = where(mag LE faint)
   sel = append_array(sel, w)
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 ; bright -- brightest magnitude to select
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 bright = extra_value(keyvals, 'bright', 'str')
 if(keyword_set(bright)) then $
  begin
   w = where(mag GE bright)
   sel = append_array(sel, w)
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 ; nbright -- number of brightest stars to select
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 nbright = extra_value(keyvals, 'nbright', 'str')
 if(keyword_set(nbright)) then $
  if(n GT nbright) then $ 
   begin
    ss = sort(mag)
    ii = lindgen(n)
    w = (ii[ss])[0:(nbright<n)-1]
    sel = append_array(sel, w)
   end


 ;------------------------------------------------------------------------
 ; implement any selections
 ;------------------------------------------------------------------------
 pg_cull_bodies, sd, sel, name=name

end
;===========================================================================



;===========================================================================
; pg_get_stars
;
;===========================================================================
function pg_get_stars, arg1, arg2, sd=_sd, od=od, _extra=keyvals, $
                     override=override, verbatim=verbatim, raw=raw, count=count, $
                              @str__keywords_tree.include
                              @dat__keywords.include
                              @dat_trs_keywords_include.pro
                              end_keywords

 count = 0

 ;------------------------------------------------------------------------
 ; sort out arguments
 ;------------------------------------------------------------------------
 pg_sort_args, arg1, arg2, dd=dd, od=od, time=time, $
                          trs=trs, free=free, $
                          @dat__keywords.include
                          end_keywords

 ndd = n_elements(dd)

 ;---------------------------------------------------------------------
 ; add selection keywords to translator keywords and filter out any
 ; prefixed keywords that don't apply
 ;---------------------------------------------------------------------
 if(keyword_set(keyvals)) then pg_add_selections, trs, keyvals, 'STR'

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)

 ;-------------------------------------------------------------------
 ; if /override, create descriptors without calling translators
 ;-------------------------------------------------------------------
 if(keyword__set(override)) then $
  begin
   n = n_elements(name)

   if(keyword_set(dd)) then gd = cor_create_gd(dd, gd=gd)
   sd = str_create_descriptors(n, $
                     @str__keywords_tree.include
                     end_keywords)

   if(keyword_set(free)) then nv_free, dd
  end $
 ;-------------------------------------------------------------------
 ; otherwise, get star descriptors from the translators
 ;-------------------------------------------------------------------
 else $
  begin
   ;-----------------------------------------------
   ; call translators
   ;-----------------------------------------------
   sd = dat_get_value(dd, 'STR_DESCRIPTORS', key1=od, key4=_sd, $
                 key7=time, key8=name, trs=trs, $
                              @dat_trs_keywords_include.pro
                              end_keywords)

   ;------------------------------------------------------------------------
   ; Free dd if pg_sort_args determined that it will not be used outside 
   ; this function.  Note that the object ID is not lost will still appear
   ; in the gd.
   ;------------------------------------------------------------------------
   if(keyword_set(free)) then nv_free, dd

   if(NOT keyword__set(sd)) then return, obj_new()

   n = n_elements(sd)

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
     tr_names = cor_name(sd)
     sub = nwhere(strupcase(tr_names), strupcase(name))
     if(sub[0] EQ -1) then return, obj_new()
     if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
    end $
   else sub=lindgen(n)

   n = n_elements(sub)
   sd = sd[sub]

   ;------------------------------------------------------------------
   ; perform aberration corrections
   ;------------------------------------------------------------------
   if(keyword_set(od) AND (NOT keyword_set(raw))) then $
    for i=0, ndd-1 do $
     begin
      w = where(cor_gd(sd, /dd) EQ dd[i])
      if(w[0] NE -1) then abcorr, od[i], sd[w], c=const_get('c')
     end

   ;-------------------------------------------------------------------
   ; override the specified values (name cannot be overridden)
   ;-------------------------------------------------------------------
   if(defined(name)) then _name = name & name = !null
   if(defined(time)) then _time = time & time = !null
   str_assign, sd, /noevent, $
                     @str__keywords_tree.include
                     end_keywords
    if(defined(_name)) then name = _name
    if(defined(_time)) then time = _time
  end

 ;--------------------------------------------------------
 ; filter stars
 ;--------------------------------------------------------
 if(NOT keyword_set(sd)) then return, obj_new()
 if(keyword_set(keyvals)) then $
                  pggs_select_stars, sd, od=od, name=name, _extra=keyvals
 if(NOT keyword_set(sd)) then return, obj_new()


 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if((obj_valid(dd))[0]) then dat_set_gd, dd, gd, sd=sd, od=od, /noevent
 dat_set_gd, sd, gd, od=od, /noevent

 count = n_elements(sd)
 return, sd
end
;===========================================================================



