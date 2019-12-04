;=============================================================================
;+
; NAME:
;	graft
;
;
; PURPOSE:
;	Grafts POINT arrays into GRIM.  
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	graft, arg
;
;
; ARGUMENTS:
;  INPUT:
;	arg:	POINT object or array of image points.  
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	pn:	 Plane number to access.  If not given, then current plane
;		 is used.
;
;	grn:	 ID of GRIM instance to use.  If not given, then current one
;		 is used.
;
;	tag:	 Tag of GRIM window to access.
;
;	psym:	 Plotting symbol.
;
;	name:	 If given, the array is added as user data with this name.
;		 Otherwise a name is created based on the desciption and name in 
;		 the point object.  If the argument is not an object, then a 
;		 unique default name is created.
;
;	symsize: Plotting symbol size.
;
;	color:	 Plotting color.
;
;	psym:	 Plotting symbol.
;
;
;
; EXAMPLE:
;	(1) Open a GRIM window, load an image, and compute planet centers.
;
;	(2) At the command line, type:
;
;		IDL> grift, gd=gd
;		IDL> limb_ptd = pg_limb(gd=gd, gbx=gd.pd)
;		IDL> graft, limb_ptd
;
;	GRIM should plot the new overlay.
;
;
; SEE ALSO:
;	grim, grift
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================



;=============================================================================
; graft_name
;
;=============================================================================
function graft_name, base, index
 return, base + strtrim(index,2)
end
;=============================================================================



;=============================================================================
; graft_default_name
;
;=============================================================================
function graft_default_name, plane, base=base

 max = 1000
 if(NOT keyword_set(base)) then base = 'NONAME-'

 user_ptd = grim_ptd(plane, /user)
 if(NOT keyword_set(user_ptd)) then return, graft_name(base, 0)

 names = cor_name(user_ptd)
 for i=0, max do $
  begin
   name = graft_name(base, i)
   w = where(str_tail(names, strlen(name)) EQ name)
   if(w[0] EQ -1) then return, name
  end

end
;=============================================================================



;=============================================================================
; graft
;
;=============================================================================
pro graft, arg, $
   psym=psym, symsize=symsize, color=_color, name=name, pn=pn, grn=grn, tag=tag, $
   fn_color=fn_color, fn_shade=fn_shade, xgraphics=xgraphics, xradius=xradius, $
   lock=lock

 ;------------------------------------------------------------------
 ; determine which GRIM window
 ;------------------------------------------------------------------
 if(keyword_set(tag)) then grn = grim_tag_to_grn(tag)
 if(keyword_set(grn)) then $
                     grim_data = grim_get_data(grim_grn_to_top(grn)) $
 else grim_data = grim_get_data(/primary)

 refresh = 0


 ;------------------------------------------------------------------
 ; determine which GRIM plane
 ;------------------------------------------------------------------
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 if(NOT defined(pn)) then $
    if(n_elements(dim) EQ 1) then pn = plane.pn

 if(defined(pn)) then $
  begin
   w = where(grim_data.pn EQ pn)
   if(w[0] NE -1) then refresh = 1
   plane = planes[pn]
  end $
 else refresh = 1


 ;----------------------------------------
 ; parse argument
 ;----------------------------------------
 type = size(arg, /type)


 if(type EQ 11) then ptd = arg $
 else ptd = pnt_create_descriptors(points=arg)


 if(type EQ 11) then ptd = arg $
 else $
  begin
   dim = size(arg, /dim)
   ndim = n_elements(dim)

   error = 0
   if(dim[0] EQ 2) then pp = arg $
   else if(ndim EQ 1) then error = 1 $
   else if(dim[1] NE 3) then error = 1 $
   else vv = arg

   if(error) then nv_message, 'Invalid input.'

   ptd = pnt_create_descriptors(points=pp, vectors=vv, name=name)
  end

 if(keyword_set(name)) then ptd = pnt_compress(ptd)


 ;------------------------------------------------------------------
 ; determine name
 ;------------------------------------------------------------------
 if(NOT keyword_set(name)) then $
   for i=0, n_elements(ptd)-1 do $
    begin
     if(NOT keyword_set(pnt_desc(ptd[i]))) then $
                 pnt_set_desc, ptd[i], graft_default_name(plane, base='UNKNOWN')
     if(NOT keyword_set(cor_name(ptd[i]))) then $
                                  cor_set_name, ptd[i], graft_default_name(plane)
     name = append_array(name, pnt_desc(ptd[i]) + '-' + cor_name(ptd[i]))
    end
   

 ;------------------------------------------------------------------
 ; parse color input
 ;------------------------------------------------------------------
 if(keyword__set(_color)) then $
    if(size(_color, /type) NE 7) then __color = ctlookup(_color)
 if(keyword__set(__color)) then color = __color


 ;------------------------------
 ; set user points
 ;------------------------------
 for i=0, n_elements(ptd)-1 do $
     grim_add_user_points, plane=plane, ptd[i], $
           name[i], psym=psym, symsize=symsize, color=color, /no_refresh, $
           fn_color=fn_color, fn_shade=fn_shade, xgraphics=xgraphics, xradius=xradius, lock=lock


 if(refresh) then grim_refresh, grim_data;, /no_image

end
;=============================================================================



