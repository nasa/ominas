;=============================================================================
;+
; NAME:
;	pnt_points
;
;
; PURPOSE:
;	Returns the points associated with a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	points = pnt_points(ptd)
;
;
; ARGUMENTS:
;	ptd:	POINT object.  If multiple POINT objects are given, 
;		and /cat is not speciied, only pointers to the arrays are 
;		returned, and conditions and tags are not applied.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	condition:	Structure specifing a mask and a condition with which to
;			match flag values.  The structure must contain the fields
;			MASK and STATE.  MASK is a bitmask to test against
;			the flags field of the POINT object, and STATE
;			is either PS_TRUE and PS_FALSE.  Note that in this case, 
;			the values will be returned as a list, with no separation 
;			into nv and nt dimensions.
;
;	cat:		If set, arrays from multiple input objects are 
;			concatenated.
;
;	sample:		Sampling interval in the nv direction.  Default is 1.
;
;	<condition>:	All of the predefined conditions (e.g. /visible) are 
;			accepted; see pnt_condition_keywords.include.
;
;	noevent:	If set, no event is generated.
;
;  OUTPUT: 
;	segments:	Subscripts in the output array denoting segments in the 
;			(assumed) continuous curve due to the point selection 
;			conditions.
;
;
; RETURN:
;	The points associated with the POINT object, or zero.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pnt_set_points
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_points, ptd0, segments=segments, $
    sample=sample, cat=cat, condition=condition, noevent=noevent, $
@pnt_condition_keywords.include
end_keywords

 condition = pnt_condition(condition=condition, $
@pnt_condition_keywords.include 
end_keywords)

 ptd = ptd0
 if(keyword_set(cat)) then ptd = pnt_compress(ptd)

 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)

 if(n_elements(_ptd) GT 1) then result = _ptd.points_p $
 else $
  begin
   result = 0
   if(ptr_valid(_ptd.points_p)) then $
    begin
     result = *_ptd.points_p
     result = reform(result, 2,n_elements(result)/2)

     if((keyword_set(condition)) AND (ptr_valid(_ptd.flags_p))) then $
      begin
       ii = pnt_apply_condition(_ptd, condition)
       if(ii[0] NE -1) then result = result[*,ii] $
       else result = 0
      end
    end
  end

 if(keyword_set(cat)) then nv_free, ptd


 if(arg_present(segments)) then $
  begin
   if(NOT keyword_set(result)) then segments = -1 $
   else segments = compute_segments(*_ptd.points_p, ii)
  end

 if(keyword_set(sample)) then $
  begin
;stop
   ii = lindgen(_ptd.nv/sample)*sample
   result = result[*,ii]
;   segments = 
  end


 return, result
end
;===========================================================================



