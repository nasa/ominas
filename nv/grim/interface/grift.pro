;=============================================================================
;+
; NAME:
;	grift
;
;
; PURPOSE:
;	External access to GRIM data.  Purloins object and array references
;	from GRIM so that they may be manipulated on the command line or by an
;	external agent.  The returned descriptors allow direct access to the 
;	memory images of GRIM's objects, so any changes made affect the 
;	objects that GRIM is using.  GRIM monitors those objects and updates 
;	itself whenever a change occurs.  
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	grift, arg, <xd>=<xd>, <overlay>_ptd=<overlay>_ptd
;
;
; ARGUMENTS:
;  INPUT:
;	arg:	GRIM window number, GRIM tag, or GRIM data struture.  If not 
;		given, the most recently accessed grim instance is used.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	plane:	Grim plane structure(s) instead of giving pn.  Note all planes
;		must belong to the same grim instance.
;
;	pn:	Plane number(s) to access.  If not given, then current plane
;		is used.
;
;	all:	If set, all planes are used.
;
;	visible:
;		If set, all visible planes are used.
;
;	active:	If set, only active members of the selected objects are
;		returned.
;
;	grn:	Id of GRIM window to access.
;
;	tag:	Tag of GRIM window to access.
;	
;
;  OUTPUT:
;	gd:	Generic descriptor containing all of GRIM's descriptors.  
;		For multiple planes, a list is returned with each element
;		corresponding to a plane.
;
;	<xd>:	Any descriptor maintained by GRIM.
;
;	<xdx>:	Returns all descriptors containing the given class, e.g., 
;		bx, gbx, dkx.
;
;	<overlay>_ptd:
;		POINT object giving the points for the overlay of type <overlay>.
;
;	ptd:
;		POINT object giving all overlay points.
;
;	tie_ptd:
;		POINT object giving the tie points.  For multiple planes, a 
;		list is returned with each element corresponding to a plane.
;
;	curve_ptd:
;		POINT object giving the curve points.  For multiple planes, a 
;		list is returned with each element corresponding to a plane.
;
;
; EXAMPLE:
;	(1) Open a GRIM window, load an image, and compute limb points.
;
;	(2) At the command line, type:
;
;		IDL> grift, cd=cd
;		IDL> pg_repoint, [50,50], 0d, cd=cd
;
;	GRIM should detect the change to the camera descriptor and update
;	itself by recomputing the limb points and refreshing the display.
;
;
; SEE ALSO:
;	grim, graft
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grift, arg, plane=planes, pn=pn, all=all, active=active, visible=visible, grn=grn, tag=tag, $
         gd=gd, $
         dd=dd, $
         cd=cd, $
         md=md, $
         pd=pd, $
         rd=rd, $
         sd=sd, $
         std=std, $
         ard=ard, $
         ltd=ltd, $
         od=od, $
         bx=bx, $
         gbx=gbx, $
         dkx=dkx, $
         limb_ptd=limb_ptd, $
         ring_ptd=ring_ptd, $
         star_ptd=star_ptd, $
         station_ptd=station_ptd, $
         array_ptd=array_ptd, $
         term_ptd=term_ptd, $
         plgrid_ptd=plgrid_ptd, $
         center_ptd=center_ptd, $
         shadow_ptd=shadow_ptd, $
         reflection_ptd=reflection_ptd, $
         ptd=ptd, $
         tie_ptd=tie_ptd, $
         curve_ptd=curve_ptd, $
_ref_extra=ex

 ;--------------------------------------------
 ; clear output arrays
 ;--------------------------------------------
 dd = !null
 cd = !null
 md = !null
 pd = !null
 rd = !null
 sd = !null
 std = !null
 ard = !null
 ltd = !null
 od = !null
 bx = !null
 gbx = !null
 dkx = !null
 limb_ptd = !null
 ring_ptd = !null
 star_ptd = !null
 station_ptd = !null
 array_ptd = !null
 term_ptd = !null
 plgrid_ptd = !null
 center_ptd = !null
 shadow_ptd = !null
 reflection_ptd = !null
 ptd = !null
 tie_ptd = !null
 curve_ptd = !null

 ;----------------------------------------------------------------
 ; interpret argument
 ;----------------------------------------------------------------
 arg_type = size(arg, /type)
 if(arg_type EQ 8) then grim_data = arg $
 else if(arg_type EQ 7) then tag = arg $
 else if(arg_type NE 0) then grn = arg

 if(defined(tag)) then grn = grim_tag_to_grn(tag)

 if(defined(grn)) then grim_data = grim_get_data(grn=grn) $
 else grim_data = grim_get_data(/primary)

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(planes[0])

 grn = grim_data.grn

 
 ;----------------------------------------------------------------
 ; get planes
 ;----------------------------------------------------------------
 if(NOT keyword_set(planes)) then $
  begin
   if(keyword_set(all)) then planes = grim_get_plane(grim_data, /all) $
   else if(keyword_set(visible)) then planes = grim_get_plane(grim_data, /visible) $
   else planes = grim_get_plane(grim_data, pn=pn)
  end
 nplanes = n_elements(planes)
 pn = planes.pn

 ;----------------------------------------------------------------
 ; build outputs
 ;----------------------------------------------------------------
 gd = list(length=nplanes)
 tie_ptd = list(length=nplanes)
 curve_ptd = list(length=nplanes)

 for i=0, nplanes-1 do $
  begin
   plane = planes[i]

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; active objects
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(active)) then $
    begin
     ddi = (cdi = (ltdi = (odi = !null)))
     pd = append_array(active_pd, (pdi=grim_xd(plane, /planet, /active)))
     rd = append_array(active_rd, (rdi=grim_xd(plane, /ring, /active)))
     sd = append_array(active_sd, (sdi=grim_xd(plane, /star, /active)))
     std = append_array(active_std, (stdi=grim_xd(plane, /station, /active)))
     ard = append_array(active_ard, (ardi=grim_xd(plane, /array, /active)))
     bx = append_array(active_bx, (bxi=grim_xd(plane, /body, /active)))
     gbx = append_array(active_gbx, (gbxi=grim_xd(plane, /globe, /active)))
     dkx = append_array(active_dkx, (dkxi=grim_xd(plane, /disk, /active)))

     limb_ptd = append_array(limb_ptd, grim_ptd(plane, /limb, /active))
     ring_ptd = append_array(ring_ptd, grim_ptd(plane, /ring, /active))
     star_ptd = append_array(star_ptd, grim_ptd(plane, /star, /active))
     term_ptd = append_array(term_ptd, grim_ptd(plane, /terminator, /active))
     plgrid_ptd = append_array(plgrid_ptd, grim_ptd(plane, /planet_grid, /active))
     center_ptd = append_array(center_ptd, grim_ptd(plane, /center, /active))
     shadow_ptd = append_array(shadow_ptd, grim_ptd(plane, /shadow, /active))
     reflection_ptd = append_array(reflection_ptd, grim_ptd(plane, /reflection, /active))
     station_ptd = append_array(station_ptd, grim_ptd(plane, /station, /active))
     array_ptd = append_array(array_ptd, grim_ptd(plane, /array, /active))
     ptd = append_array(ptd, grim_xd(plane, /active))
    end $
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; all objects
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else $
    begin
     dd = cor_cull(append_array(dd, (ddi=plane.dd)))
     cd = cor_cull(append_array(cd, (cdi=grim_xd(plane, /cd))))
     if(keyword_set(cd)) then if(cor_class(cd[0]) EQ 'MAP') then md = cd
     pd = cor_cull(append_array(pd, (pdi=grim_xd(plane, /pd))))
     rd = cor_cull(append_array(rd, (rdi=grim_xd(plane, /rd))))
     sd = cor_cull(append_array(sd, (sdi=grim_xd(plane, /sd))))
     std = cor_cull(append_array(std, (stdi=grim_xd(plane, /std))))
     ard = cor_cull(append_array(ard, (ardi=grim_xd(plane, /ard))))
     ltd = cor_cull(append_array(ltd, (ltdi=grim_xd(plane, /ltd))))
     od = cor_cull(append_array(od, (odi=grim_xd(plane, /od))))
     bx = cor_cull(append_array(bx, (bxi=grim_xd(plane, /bx))))
     gbx = cor_cull(append_array(gbx, (gbxi=grim_xd(plane, /gbx))))
     dkx = cor_cull(append_array(dkx, (dkxi=grim_xd(plane, /dkx))))

     limb_ptd = append_array(limb_ptd, grim_ptd(plane, /limb))
     ring_ptd = append_array(ring_ptd, grim_ptd(plane, /ring))
     star_ptd = append_array(star_ptd, grim_ptd(plane, /star))
     term_ptd = append_array(term_ptd, grim_ptd(plane, /terminator)) 
     plgrid_ptd = append_array(plgrid_ptd, grim_ptd(plane, /planet_grid)) 
     center_ptd = append_array(center_ptd, grim_ptd(plane, /center)) 
     shadow_ptd = append_array(shadow_ptd, grim_ptd(plane, /shadow)) 
     reflection_ptd = append_array(reflection_ptd, grim_ptd(plane, /reflection)) 
     station_ptd = append_array(station_ptd, grim_ptd(plane, /station)) 
     array_ptd = append_array(array_ptd, grim_ptd(plane, /array)) 
     ptd = append_array(ptd, grim_ptd(planes[i]))
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; tie points and curves
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   tie_ptd[i] = *plane.tiepoint_ptdp
   curve_ptd[i] = *plane.curve_ptdp

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; generic descriptor
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   gd[i] = cor_create_gd(dd=ddi, cd=cdi, pd=pdi, rd=rdi, $
                            ltd=ltdi, sd=sdi, ard=ardi, std=stdi, od=odi)
  end

 ;------------------------------------------------------------------
 ; don't return lists if only one plane
 ;------------------------------------------------------------------
 if(nplanes EQ 1) then $
  begin
   if((n_elements(gd) EQ 1) AND (NOT keyword_set(gd[0]))) then gd = !null $
   else gd = gd.ToArray()
   tie_ptd = tie_ptd.ToArray()
   curve_ptd = curve_ptd.ToArray()
  end


end
;=============================================================================
