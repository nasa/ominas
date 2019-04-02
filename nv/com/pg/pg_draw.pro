;=============================================================================
;+
; NAME:
;	pg_draw
;
;
; PURPOSE:
;	Calls pg_draw_point or pg_draw_vector depending on the input arrays.
;	pg_draw_point is called is only one argument is given.  Otherwise,
;	it assumed that a source and target are given and pg_draw_vector is 
;	called.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_draw, object_ptd, target_ptd
;
;
; ARGUMENTS:
;  INPUT:
;	object_ptd:	Array of POINT containing image points
;			to be plotted in the current data coordinate system.
;			Or inertial vectors to be used as vector sources.
;			May also be an array of image points or inertial
;			vectors.
;
;	target_ptd:	Array of POINTs giving the inertial
;			positions of vector targets.  May also be an
;			array of inertial vectors.  If this argument is
;			present, then vectors are drawn instead of points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS: 
;	graphics:	Logical operation to use for drawing.
;
;	suspend:	If set, pg_draw output will be suspended until 
;			/resume is received.
;
;	resume:		Cancels a prior /suspend.
;
;	See pg_draw or pg_draw_vector for more keywords.
;
;
; RETURN:
;	NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2005
;	
;-
;=============================================================================
pro pg_draw, object_ptd, target_ptd, $
             literal=literal, $
             colors=colors, shades=shades, psyms=psyms, psizes=psizes, plabels=plabels, $
             xormode=xormode, csizes=csizes, cthicks=cthicks, wnum=wnum, label_shade=label_shade, $
             label_points=label_points, thick=thick, line=line, print=print, $
             cd=cd, gd=gd, corient=corient, $
             lengths=lengths, align=align, $
             noshorten=noshorten, solid=solid, $
             fixedheads=fixedheads, winglength=winglength, $
             graphics=graphics, label_color=label_color, $
             shade_threshold=shade_threshold, suspend=suspend, resume=resume
common pg_draw_block, pixmap, ___suspend

 if(keyword_set(suspend)) then ___suspend = 1
 if(keyword_set(resume)) then ___suspend = 0
 if(keyword_set(___suspend)) then return

 if(windows_output()) then $
 if(keyword_set(graphics)) then $
  begin
   device, get_graphics=graphics_orig
   device, set_graphics=graphics
  end



 if(NOT keyword_set(target_ptd)) then $
  pg_draw_point, $
             object_ptd, literal=literal, label_shade=label_shade, cthicks=cthicks, $
             colors=colors, shades=shades, psyms=psyms, psizes=psizes, plabels=plabels, $
             xormode=xormode, csizes=csizes, wnum=wnum, align=align, corient=corient, $
             label_points=label_points, thick=thick, line=line, print=print, label_color=label_color, $
             shade_threshold=shade_threshold $
 else pg_draw_vector, $
    object_ptd, target_ptd, cd=cd, gd=gd, literal=literal, label_shade=label_shade, $
    lengths=_lengths, plabels=plabels, colors=colors, thick=thick, $
    csizes=csizes, wnum=wnum, noshorten=noshorten, solid=solid, $
    fixedheads=fixedheads, winglength=winglength, shades=shades, label_color=label_color, $
    shade_threshold



 if(defined(orig_wnum)) then wset, orig_wnum
 if(windows_output()) then $
    if(keyword_set(graphics)) then device, set_graphics=graphics_orig

end
;=============================================================================
