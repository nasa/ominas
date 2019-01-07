;=============================================================================
;+
; NAME:
;	dat_get_value
;
;
; PURPOSE:
;	Calls input translators, supplying the given keyword, and builds 
;	a list of returned descriptors.  Translators that crash are ignored 
;	and a warning is issued.  This behavior is disabled if $NV_DEBUG is 
;	set.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	xds = dat_get_value(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptors.  Must all have the same instrument 
;			string.
;
;	keyword:	Keyword to pass to translators, describing the
;			requested quantity.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	trs:		Transient argument string.
;
;	tr_disable:	If set, dat_get_value returns without performing 
;			any action.
;
;	tr_override:	Comma-delimited list of translators to use instead
;			of those stored in dd.
;
;	tr_first:	If set, dat_get_value returns after the first
;			successful translator.
;
;	tr_nosort:	By default, output descriptors are sorted to remove
;			those with duplicate names, retaining only the first
;			descriptor of a given name for each input data 
;			descriptor.  /tr_nosort disables this action.
;
;	tr_order:	If set (and tr_nosort not set), dat_get_value selects 
;			the latest of any duplicately named output descriptors 
;			instead of the earliest.
;
;
;  OUTPUT: 
;	status:		0 if at least one translator call was successful, 
;			-1 otherwise.
;
;
; RETURN: 
;	Array of descriptors returned from all successful translator calls.
;	Descriptors are returned in the same order that the corresponding 
;	translators were called.  Each translator may produce multiple 
;	descriptors.  0 if no result.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_get_value, dd, keyword, status=status, trs=trs, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
                             end_keywords
@core.include

 ndd = n_elements(dd)

 status = -1
 xds = 0

 if(keyword_set(tr_disable)) then return, 0

 ;--------------------------------------------
 ; record any transient keyvals
 ;--------------------------------------------
 nv_message, verb=0.9, 'Adding transient keywords: ' + trs
 dat_add_tr_transient_keyvals, dd, trs


 ;--------------------------------------------
 ; build translators list
 ;--------------------------------------------
 _dd = cor_dereference(dd)

; need to group dd based on instrument...
 if(NOT keyword_set(tr_override)) then $
  begin
   if(NOT ptr_valid(_dd[0].input_translators_p)) then $
    begin
     nv_message, /con, name='dat_get_value', $
	                      'No input translator available for '+keyword+'.'
     return, 0
    end
   translators = *_dd[0].input_translators_p
  end $
 else translators = str_nsplit(tr_override, ',')
 n = n_elements(translators)


 ;----------------------------------------------------------------
 ; call all translators, building a list of returned values
 ;----------------------------------------------------------------
 catch_errors = NOT keyword_set(getenv('NV_DEBUG'))
 nv_suspend_events
 nv_message, verb=0.9, 'Data descriptors ' + str_comma_list(cor_name(dd))
 nv_message, verb=0.9, 'Keyword ' + keyword

 for i=0, n-1 do $
  begin
   nv_message, verb=0.9, 'Calling translator ' + translators[i]

   stat = -1
   if(keyword_set(translators[i])) then $
    begin
     if(NOT catch_errors) then err = 0 $
     else catch, err

     if(err NE 0) then $
          nv_message, /warning, $
            'Translator ' + strupcase(translators[i]) + ' crashed; ignoring.' $
     else $
       xd = call_function(translators[i], dd, keyword, values=xds, stat=stat, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
		    end_keywords)

     catch, /cancel
    end

   ;--------------------------------------
   ; add values to list
   ;--------------------------------------
   if(stat EQ 0) then $
    begin
     nv_message, verb=0.9, $
                    'Returned descriptors: ' + str_comma_list([cor_name(xd)])

     if(keyword_set(xd)) then $
      begin 
       for jj = 0, n_elements(xd)-1 do $
                           cor_set_udata, xd[jj], 'TRANSLATOR', translators[i]
       xds = append_array(xds, xd)
       sort_names = append_array(sort_names, $
               cor_name(xd) + '-' + str_pad(strtrim(i,2), 4, c='0', align=1))
      end

     if(keyword_set(tr_first)) then i=n
    end $
   else nv_message, verb=0.9, 'No value.' 
  end 
 nxds = n_elements(xds)

 ;----------------------------------------------------------------
 ; sort xds: remove descriptors with duplicate names, keeping
 ; the earliest (or latest if /tr_order) returned versions
 ;----------------------------------------------------------------
 result = 0
 if(keyword_set(xds)) then $
  begin
   status = 0
   if(NOT keyword_set(tr_nosort)) then $
    for i=0, ndd-1 do $
     begin
      ;- - - - - - - - - - - - - - - - - - - - - - - - - -
      ; get xds related to dd[i]
      ;- - - - - - - - - - - - - - - - - - - - - - - - - -
      w = where(cor_gd(xds, /dd) EQ dd[i])
      if(w[0] NE -1) then $
       begin
        xdw = xds[w]

        ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ; sort by name in order of translator 
        ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
        names = cor_name(xdw)
	ss = sort(sort_names[w])

        ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ; uniq chooses highest index, so this ensures
        ; that earliest xd gets selected unless /tr_order
        ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if(NOT keyword_set(tr_order)) then ss = rotate(ss,2)	
        uu = uniq(names[ss])
        ii = ss[uu]

        xdw = xdw[ii]

        nv_message, verb=0.9, $
           'Selecting results from translator ' + cor_udata(xdw, 'TRANSLATOR')

        result = append_array(result, xdw)
       end
     end $
    else result = xds
  end

 nv_message, verb=0.9, 'Output descriptors: ' + str_comma_list([cor_name(result)])

 nv_resume_events
 return, result
end
;===========================================================================
