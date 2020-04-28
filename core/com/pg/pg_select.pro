;=============================================================================
;+
; NAME:
;	pg_select
;
;
; PURPOSE:
;	Allows the user to select objects in an image using the mouse.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	region = pg_select(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor containing the image.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	silent: 	If set, turns off the notification that cursor
;			movement is required.
;
;	psym: 		Plotting symbol to use for plotting points.
;
;	one:		If set, the routine will exit after selecting one point.
;
;	number:		If set, points will be labeled with numbers.
;
;	region:		If set, the user selects a region in the image.
;			This is the default.
;
;	points:		If set, the user selects points.
;
;  OUTPUT: 
;	cancelled:	Set if routine is caused to return by the cancel button.
;
;
; RETURN:
;	Array of subscripts of all image points which lie within the selected
;	region.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_trim
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function pg_select, dd, silent=silent, region=region, points=points

 if(keyword__set(points)) then $
        return, pg_select_points(dd, psym=psym, silent=silent, $
                               one=one, number=number, cancelled=cancelled) $
 else return, pg_select_region(dd, silent=silent)

end
;=============================================================================
