;=============================================================================
;+
; NAME:
;	pg_get_cameras
;
;
; PURPOSE:
;	Obtains a camera descriptor for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_cameras(arg1, arg2)
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
;	cd:		Input camera descriptors; used by some translators.
;
;	gd:		Generic descriptor containing the above descriptors.
;			Note this keyword is inherited from the CORE keywords 
;			list.
;
;	override:	Create a data descriptor and initilaize with the 
;			given values.  Translators will not be called.
;
;	verbatim:	If set, the descriptors requested using cam_name
;			are returned in the order requested.  Otherwise, the 
;			order is determined by the translators.
;
;	tr_override:	String giving a comma-separated list of translators
;			to use instead of those in the translators table.  If
;			this keyword is specified, no translators from the 
;			table are called, but the translators keywords
;			from the table are still used.  
;
;	default_orient:	Default orientation matrix to use if camera
;			orientation is not available.  If not specified, 
;			the identity matrix is used.
;
;
;	CAMERA Keywords
;	---------------
;	All CAMERA override keywords are accepted.  See cam__keywords.include.  
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
;	Array of camera descriptors, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a camera descriptor is created and initialized
;	using the specified values.  Otherwise, the descriptor is obtained
;	through the translators.  Note that if /override is not used,
;	values (except cam_name) can still be overridden by specifying 
;	them as keyword parameters.  If cam_name is specified, then
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
function pg_get_cameras, arg1, arg2, cd=_cd, od=od, pd=pd, _extra=keyvals, $
                          override=override, verbatim=verbatim, default_orient=default_orient, $
                          no_default=no_default, count=count, $
                              @cam__keywords_tree.include
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

 ;---------------------------------------------------------------------
 ; add selection keywords to translator keywords and filter out any
 ; prefixed keywords that don't apply
 ;---------------------------------------------------------------------
 if(keyword_set(keyvals)) then pg_add_selections, trs, keyvals, 'CAM'

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)

 if(keyword_set(od)) then $
   if(n_elements(od) NE n_elements(dd)) then $
           nv_message, 'One observer descriptor required for each data descriptor'

 ;-------------------------------------------------------------------
 ; if /override, create descriptors without calling translators
 ;-------------------------------------------------------------------
 if(keyword_set(override)) then $
  begin
   n = n_elements(name)

   if(keyword_set(dd)) then gd = cor_create_gd(dd, gd=gd)
   cd = cam_create_descriptors(n, $
               @cam__keywords_tree.include
               end_keywords)

   if(keyword_set(free)) then nv_free, dd
  end $
 ;-------------------------------------------------------------------
 ; otherwise, get planet descriptors from the translators
 ;-------------------------------------------------------------------
 else $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; default orientation is identity matrix unless otherwise specifed
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(NOT keyword_set(default_orient)) then default_orient = idgen(3)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Get the source dd if this is a slice
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   dd0 = dat_slice_source(dd)

   ;-----------------------------------------------
   ; call translators
   ;-----------------------------------------------
   cd = dat_get_value(dd0, 'CAM_DESCRIPTORS', key1=od, key2=pd, key4=_cd, key3=default_orient, $
                             key7=time, key8=name, trs=trs, $
                              @dat_trs_keywords_include.pro
                              end_keywords)

   ;------------------------------------------------------------------------
   ; Free dd if pg_sort_args determined that it will not be used outside 
   ; this function.  Note that the object ID is not lost will still appear
   ; in the gd.
   ;------------------------------------------------------------------------
   if(keyword_set(free)) then nv_free, dd
   if(NOT keyword_set(cd)) then return, obj_new()

   ;-----------------------------------------------
   ; Select relevant cds if this is a slice
   ;-----------------------------------------------
   cd = dat_slice_select(dd, cd)
   n = n_elements(cd)

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
     tr_names = cor_name(cd)
     sub = nwhere(strupcase(tr_names), strupcase(name))
     if(sub[0] EQ -1) then return, obj_new()
     if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
    end $
   else sub=lindgen(n)

   n = n_elements(sub)
   cd = cd[sub]

   ;---------------------------------------------------------------------
   ; override the specified values (name and time cannot be overridden)
   ;---------------------------------------------------------------------
; this might be cleaner using the _extra mechanism
   if(defined(name)) then _name = name & name = !null
   if(defined(time)) then _time = time & time = !null
   cam_assign, cd, /noevent, $
                 @cam__keywords_tree.include
                 end_keywords
    if(defined(_name)) then name = _name
    if(defined(_time)) then time = _time
  end


 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if((obj_valid(dd))[0]) then dat_set_gd, dd, gd, cd=cd, bx=bx, /noevent
 dat_set_gd, cd, gd, bx=bx, /noevent

 count = n_elements(cd)
 return, cd
end
;===========================================================================








