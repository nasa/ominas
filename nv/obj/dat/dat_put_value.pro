;=============================================================================
;+
; NAME:
;	dat_put_value
;
;
; PURPOSE:
;	Calls output translators, supplying the given keyword and value.
;	Translators that crash are ignored and a warning is issued.  This 
;	behavior is disabled if $NV_DEBUG is set.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_put_value, dd, keyword, value
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	Keyword to pass to translators, describing the
;			requested quantity.
;
;	value:		Value to write through the translators.
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
;  OUTPUT: 
;	status:		0 if at least one translator call was successful, 
;			-1 otherwise.
;
;
; RETURN: NONE
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
pro dat_put_value, dd, keyword, value, trs=trs, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
                             end_keywords
@core.include

 status = 0
 if(keyword__set(tr_disable)) then return


 ;--------------------------------------------
 ; record any transient keyvals
 ;--------------------------------------------
 dat_add_tr_transient_keyvals, dd, trs


 ;--------------------------------------------
 ; send value through all output translators
 ;--------------------------------------------
 _dd = cor_dereference(dd)
 if(NOT ptr_valid(_dd.output_translators_p)) then $
  begin
   status = -1
   return
  end

 nv_suspend_events
; i=0
; translators=*_dd.output_translators_p
; n=n_elements(translators)

 if(NOT keyword__set(tr_override)) then translators=*_dd.output_translators_p $
 else translators = str_nsplit(tr_override, ',')
 n=n_elements(translators)

 catch_errors = NOT keyword_set(getenv('NV_DEBUG'))
 for i=0, n-1 do $
  begin
   nv_message, verb=0.9, 'Calling translator ' + translators[i]

   if(keyword_set(translators[i])) then $
    begin
     if(NOT catch_errors) then err = 0 $
     else catch, err

     if(err NE 0) then $
          nv_message, /warning, $
              'Translator ' + strupcase(translators[i]) + ' crashed; ignoring.' $
     else $
       call_procedure, translators[i], dd, keyword, value, stat=stat, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
                      end_keywords

     catch, /cancel
    end

   _dd = cor_dereference(dd)
  end


 nv_resume_events
 cor_rereference, dd, _dd
end
;===========================================================================
