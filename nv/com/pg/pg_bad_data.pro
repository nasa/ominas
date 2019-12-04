;=============================================================================
;+
; NAME:
;	pg_bad_data
;
;
; PURPOSE:
;	Locates areas of bad data values like saturation and dropouts.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_bad_data(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor containing the image to be despiked.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	dropout:	Value to use for dropouts.  Default is 0
;
;	sat:		If given, value above which to flag as saturated, 
;			inclusive.
;
;	mask:		Byte image of the same size as the input image
;			in which nonzero pixel values indicate locations
;			where problems should not be flagged.
;
;	extend:		Number of pixels away from masked pixels before
;			locations may be flagged as spikes.
;
;	edge:		Regions closer than this to the edge of the image
;			will be ignored.  Default is 0.
;
;  OUTPUT:
;	subscripts:	Subscript of each bad point.
;
;
; RETURN:
;	POINT objects containing the detected bad points.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_spikes
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
function pg_bad_data, dd, dropout=dropout, sat=sat, mask=mask, extend=extend, $
             edge=edge, subscripts=ii

 if(NOT keyword_set(dropout)) then dropout = 0
 if(NOT keyword_set(edge)) then edge = 0
 if(NOT keyword_set(sat)) then sat = 1d

 ;---------------------------------------
 ; dereference the data descriptor
 ;---------------------------------------
 im = dat_data(dd)


 ;---------------------------------------
 ; find dropouts
 ;---------------------------------------
 w = where(im EQ dropout)
 if(w[0] NE -1) then ii = w


 ;---------------------------------------
 ; find saturated points
 ;---------------------------------------
 w = where(im GE sat)
 if(w[0] NE -1) then ii = append_array(ii, w)


 ;---------------------------------------
 ; copmute coordinates
 ;---------------------------------------
 if(NOT keyword_set(ii)) then return, 0
 p = w_to_xy(im, ii)


 ;---------------------------------------
 ; set up the POINT object
 ;---------------------------------------
  ptd = pnt_create_descriptors(points = p, desc = 'BAD_DATA')

 return, ptd
end
;=============================================================================




