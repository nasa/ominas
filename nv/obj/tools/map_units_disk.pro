;=============================================================================
;+
; NAME:
;       map_units_disk
;
;
; PURPOSE:
;	Computes units for a map descriptor given pixel scales for
;	the map center.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       v = map_units_disk(md, resrad=resrad, reslon=reslon)
;
;
; ARGUMENTS:
;  INPUT:
;	md:	Map descriptor.
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: 
;	resrad:	Scale (length/pixel) in radial direction.
;
;	reslon:	Scale (radians/pixel) in longitude direction.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (2) giving the map units.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function map_units_disk, md, resrad=resrad, reslon=reslon

 size = map_size(md)

 units = [!dpi/size[1] / resrad, 2d*!dpi/size[0] / reslon]

 return, units
end
;=============================================================================
