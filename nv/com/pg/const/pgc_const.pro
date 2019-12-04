;=============================================================================
;+
; NAME:
;       pgc_const
;
;
; PURPOSE:
;       Returns the values of physical constants relative to whatever system
;	of units is selected.
;
;
; CATEGORY:
;       NV/PGC
;
;
; CALLING SEQUENCE:
;       result = pgc_const(name, units=units)
;
;
; ARGUMENTS:
;  INPUT:
;       name:	String giving the name of the desired constant.
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;  INPUT:
;       units:	String giving the name of the unit system.  If not given,
;		first the comomn block is checked for any unit system
;		set using pgc_set_units.  If no unit system exists, then
;		the environment variable PGC_UNITS is checked.  If still no
;		unit system ecists, then it defaults to 'mks'.
;
;  OUTPUT:
;       NONE
;
;
; ENVIRONMENT VARIABLES:
;       PGC_UNITS:    	Selects the unit system to use if one has not been set 
;			using pgc_set_units.
;
;
; RETURN:
;       The value of the named constant is returned relative to the selected
;	unit system.
;
;
; PROCEDURE:
;	The name of the selected units system is taken as a prefix for 
;	the function <prefix>_const, which takes the name of a unit as input
;	and returns the value of the selected constant.  See mks_const.pro
;	for an example.
;
;
; COMMON BLOCKS:
;       pgc_block:     Stores the name of the software-selected unit system.
;
;
; STATUS:
;       Complete
;
;
; SEE ALSO:
;       pgc_set_units, mks_const
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 3/2006
;
;-
;=============================================================================
function pgc_const, name, units=units

 if(NOT keyword_set(units)) then units = pgc_get_units()

 result = call_function(strlowcase(units) + '_' + 'const', name)

 return, result
end
;============================================================================
