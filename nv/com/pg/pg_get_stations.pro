;=============================================================================
;+
; NAME:
;	pg_get_stations
;
;
; PURPOSE:
;	Obtains a station descriptor for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_stations(arg1, arg2)
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
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	std:		Input station descriptors; used by some translators.
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
;	STATION Keywords
;	---------------
;	All STATION override keywords are accepted.  See stn__keywords.include.  
;	If 'name' is specified, then only descriptors with those names are 
;	returned.
;
;	DATA Keywords
;	-------------
;	All DATA override keywords are accepted.  See dat__keywords.include.  
;
;
; RETURN:
;	Array of station descriptors, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a station descriptor is created and initialized
;	using the specified values.  Otherwise, the descriptor is obtained
;	through the translators.  Note that if /override is not used,
;	values (except name) can still be overridden by specifying 
;	them as keyword parameters.  If name is specified, then
;	only descriptors corresponding to those names will be returned.
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2009
;	
;-
;=============================================================================
function pg_get_stations, arg1, arg2, od=od, bx=bx, std=_std, _extra=keyvals, $
                          override=override, verbatim=verbatim, $
                              @stn__keywords_tree.include
                              @dat__keywords.include
                              @nv_trs_keywords_include.pro
                              end_keywords

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
 if(keyword_set(keyvals)) then pg_add_selections, trs, keyvals, 'STN'

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)


 ;-----------------------------------------------
 ; call translators
 ;-----------------------------------------------
 std = dat_get_value(dd, 'STN_DESCRIPTORS', key1=od, key2=bx, key4=_std, key6=primary, $
                             key7=time, key8=name, trs=trs, $
                              @nv_trs_keywords_include.pro
                              end_keywords)

 ;------------------------------------------------------------------------
 ; Free dd if pg_sort_args determined that it will not be used outside 
 ; this function.  Note that the object ID is not lost will still appear
 ; in the gd.
 ;------------------------------------------------------------------------
 if(keyword_set(free)) then nv_free, dd

 if(NOT keyword_set(std)) then return, obj_new()

 n = n_elements(std)

 ;---------------------------------------------------
 ; If name given, determine subscripts such that
 ; only values of the named objects are returned.
 ;
 ; Note that each translator has this opportunity,
 ; but this code guarantees that it is done.
 ;
 ; If stn_name is not given, then all descriptors
 ; will be returned.
 ;---------------------------------------------------
 if(keyword__set(name)) then $
  begin
   tr_names = cor_name(std)
   sub = nwhere(strupcase(tr_names), strupcase(name))
   if(sub[0] EQ -1) then return, obj_new()
   if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
  end $
 else sub=lindgen(n)

 n = n_elements(sub)
 std = std[sub]



 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if((obj_valid(dd))[0]) then dat_set_gd, dd, gd, std=std, od=od, bx=bx, /noevent
 dat_set_gd, std, gd, od=od, bx=bx, /noevent

 return, std
end
;===========================================================================








