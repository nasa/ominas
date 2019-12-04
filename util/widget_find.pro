;==================================================================================
; wf_compare
;
;==================================================================================
function wf_compare, x, _x

 if(NOT keyword_set(x)) then return, 0
 if(NOT keyword_set(_x)) then return, 0

 type = size(x, /type)
 _type = size(_x, /type)

 if(type EQ 7) then if (_type NE 7) then return, 0
 if(_type EQ 7) then if (type NE 7) then return, 0
 if(type EQ 8) then return, 0
 if(_type EQ 8) then return, 0
 if(type EQ 9) then if (_type NE 9) then return, 0
 if(_type EQ 9) then if (type NE 9) then return, 0
 if(type EQ 10) then if (_type NE 10) then return, 0
 if(_type EQ 10) then if (type NE 10) then return, 0
 if(type EQ 11) then if (_type NE 11) then return, 0
 if(_type EQ 11) then if (type NE 11) then return, 0

 if(x NE _x) then return, 0
 return, 1
end
;==================================================================================



;==================================================================================
; wf_descend
;
;==================================================================================
function wf_descend, id, value=value, uvalue=uvalue, first=first

 if(NOT widget_info(id, /valid)) then return, -1

 match_ids = -1


 ;------------------------------------------
 ; check value of current widget 
 ;------------------------------------------
 catch, stat
 if(stat EQ 0) then widget_control, id, get_value=_value, get_uvalue=_uvalue

 if(wf_compare(value, _value)) then match_ids = append_array(match_ids, id, /pos)
 if(wf_compare(uvalue, _uvalue)) then match_ids = append_array(match_ids, id, /pos)
 if(keyword_set(first)) then if(match_ids[0] NE -1) then return, match_ids


 ;------------------------------------------
 ; descend to children
 ;------------------------------------------
 child = widget_info(id, /child)
 if(widget_info(child, /valid)) then $
  begin
    _match_ids = wf_descend(child, value=value, uvalue=uvalue, first=first)
   if(_match_ids[0] NE -1) then $
    begin
     match_ids = append_array(match_ids, _match_ids[0], /pos)
     if(first) then return, match_ids
    end
  end


 ;------------------------------------------
 ; move on to siblings
 ;------------------------------------------
 sibling = widget_info(id, /sibling)
 if(widget_info(sibling, /valid)) then $
  begin
    _match_ids = wf_descend(sibling, value=value, uvalue=uvalue, first=first)
   if(_match_ids[0] NE -1) then $
    begin
     match_ids = append_array(match_ids, _match_ids[0], /pos)
     if(first) then return, match_ids
    end
  end

 return, -1
end
;==================================================================================



;==================================================================================
; widget_find
;
;==================================================================================
function widget_find, value=value, uvalue=uvalue, first=first
  COMMON MANAGED,	ids, $		; IDs of widgets being managed
  			names, $	; and their names
			modalList	; list of active modal widgets

 match_ids = -1
 for i=0, n_elements(ids)-1 do $
  begin
   _match_ids = wf_descend(ids[i], value=value, uvalue=uvalue, first=first)
   if(_match_ids[0] NE -1) then match_ids = append_array(match_ids, _match_ids, /pos)
  end

 return, match_ids
end
;==================================================================================
