;=============================================================================
;+
; NAME:
;       get_primary
;
;
; PURPOSE:
;	Attempts to determine the primary planet from a list of descriptors
;	based on their names and proximity to the observer, or from any
;	the observer descriptor in the object's generic descriptor, or using
;	the primary descriptor in the object's generic descriptor.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       bx0 = get_primary(xd)
;       bx0 = get_primary(od, bx)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	Array of objects from which to determine primary descriptors
;		using their generic descriptors.
;
;	od:	Array (nt) of any subclass of BODY, describing the observers.
;
;	bx:	Array of any subclass of BODY, specifying a 
;		system of candidate primary objects to choose from.
;
;  OUTPUT:
;       NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	planets: Array of names of objects to consider as planets.
;		 Default is the planets of the Solar System, or the
;		 primary planet of rx, if provided.
;
;  OUTPUT: NONE
;
;
; RETURN: Array (nt) of BODY descriptor sfor the selected primaries. 
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function get_primary, arg1, arg2, planets=planets

 ;------------------------------------------------------------------
 ; if only one argument, either return primary descriptor from arg1
 ; or extract its observer descriptor
 ;------------------------------------------------------------------
 if(NOT defined(arg2)) then $
  begin
   if(cor_test_gd(arg1, 'BX0')) then return, cor_gd(arg1, /bx0)
   bx = arg1
;   od = (cor_gd(bx, /od))[0]
   od = unique(cor_gd(bx, /od))
  end $
 ;----------------------------------------------------------------
 ; otherwise, od is the first arg
 ;----------------------------------------------------------------
 else $
  begin
   od = arg1
   bx = arg2
  end
 if(NOT keyword_set(bx)) then return, 0
 nt = n_elements(od)


 if(NOT keyword_set(planets)) then $
   planets = ['mercury', 'venus', 'earth', 'mars', $
              'jupiter', 'saturn', 'uranus', 'neptune']
 planets = strlowcase(planets)

 ss = sort(planets)
 planets = planets[ss]
 uu = uniq(planets)
 planets = planets[uu]

 nplanets = n_elements(planets)

 bx0 = objarr(nt)
 for j=0, nt-1 do $
  begin
   ;------------------------------------------------
   ; determine which given bx are planets
   ;------------------------------------------------
   bxj = cor_associate_gd(bx, od[j])
   names = strlowcase(cor_name(bxj))
   for i=0, nplanets-1 do $
    begin
     w = where(strpos(names, planets[i]) NE -1)
     if(w[0] NE -1) then ii = append_array(ii, w)
    end

   if(keyword__set(ii)) then $	; keyword__set intended
    begin
     ;------------------------------------------------
     ; take closest planet
     ;------------------------------------------------
     nii = n_elements(ii)
     if(nii EQ 1) then bx0[j] = bxj[ii] $
     else $
      begin
       r0 = bod_pos(od[j]) ## make_array(nii, val=1d)

       d2 = v_sqmag(r0 - transpose(bod_pos(bxj[ii])))

       w = where(d2 EQ min(d2))
       bx0[j] = bxj[ii[w[0]]]
      end
    end
  end

 return, bx0
end
;=============================================================================




;=============================================================================
function ___get_primary, arg1, arg2, planets=planets

 ;------------------------------------------------------------------
 ; if only one argument, either return primary descriptor from arg1
 ; or extract its observer descriptor
 ;------------------------------------------------------------------
 if(NOT defined(arg2)) then $
  begin
   if(cor_test_gd(arg1, 'BX0')) then return, cor_gd(arg1, /bx0)
   bx = arg1
;   od = (cor_gd(bx, /od))[0]
   od = unique(cor_gd(bx, /od))
  end $
 ;----------------------------------------------------------------
 ; otherwise, od is the first arg
 ;----------------------------------------------------------------
 else $
  begin
   od = arg1
   bx = arg2
  end
 if(NOT keyword_set(bx)) then return, 0
 nt = n_elements(od)


 if(NOT keyword_set(planets)) then $
   planets = ['mercury', 'venus', 'earth', 'mars', $
              'jupiter', 'saturn', 'uranus', 'neptune']

 ss = sort(planets)
 planets = planets[ss]
 uu = uniq(planets)
 planets = planets[uu]

 nplanets = n_elements(planets)

 bx0 = objarr(nt)
 for j=0, nt-1 do $
  begin
   ;------------------------------------------------
   ; determine which given bx are planets
   ;------------------------------------------------
   planets = strlowcase(planets)
   names = strlowcase(cor_name(bx[*,j]))
   for i=0, nplanets-1 do $
    begin
     w = where(strpos(names, planets[i]) NE -1)
     if(w[0] NE -1) then ii = append_array(ii, w)
    end

   if(keyword__set(ii)) then $	; keyword__set intended
    begin
     ;------------------------------------------------
     ; take closest planet
     ;------------------------------------------------
     nii = n_elements(ii)
     if(nii EQ 1) then bx0[j] = bx[ii,j] $
     else $
      begin
       r0 = bod_pos(od) ## make_array(nii, val=1d)

       d2 = v_sqmag(r0 - transpose(bod_pos(bx[ii,j])))

       w = where(d2 EQ min(d2))
       bx0[j] = bx[ii[w[0]]]
      end
    end
  end

 return, bx0
end
;=============================================================================
