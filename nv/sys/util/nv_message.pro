;=============================================================================
;+
; NAME:
;	nv_message
;
;
; PURPOSE:
;	Prints an error message and halts execution.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_message, string
;
;
; ARGUMENTS:
;  INPUT:
;	string:	Message to print.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	name:		Name to use for the calling routine instead of 
;			taking it from the traceback list.
;
;	anonymous:	If set, the traceback list is not used to infer the
;			name of the calling routine.  In this case, a name
;			is printed only if explicitly specified using the 'name'
;			keyword.
;
;	continue:	If set, execution is not halted.
;
;	stop:		If set, execution is halted after a terminal message 
;			is printed.
;
;	exit:		If set, IDL is exited after a terminal message is 
;			printed.
;
;	get_message:	If set, the last message sent through nv_message
;			is returned in the _string keyword and no other
;			action is taken.
;
;	clear:		If set, the last message is cleared and no other action
;			is taken.
;
;	cb_tag:		If set, the callback procedure below is added to
;			the callback list under this tag name and no other
;			action is taken.
;
;	cb_data_p:	Pointer to data for the callback procedure.
;
;	callback:	Name of a callback procedure to add to the callback
;			list.  Callback procedures are sent two arguments:
;			cb_data_p (see above), and the message string.  
;
;	disconnect:	If set, the callback identified by the given cb_tag
;			is removed from the callback list and no other
;			action is taken.
;
;	explanation:	String giving an extended explanation for the message.
;
;	verbose:	Floating value in the range 0 to 1 specifying the 
;			verbosity threshold.  If set, and no string is given, 
;			then the threshold is set to this value.  If a string
;			is given, then it will only be printed if this 
;			value is greater than or equal to current verbosity 
;			level.  Setting this keyword implies /continue.  
;			Verbosity threshold rules of thumb are as follows:
;
;			 0.1:	Useful messages that you don't always need to 
;				see; files being loaded, written, etc.
;			 0.5:	Useful messages that you want to see even less;
;				file-not-found warnings, etc.
;			 0.9:	Debugging messages that don't produce huge
;				outputs.
;			 1.0:	Mega debugging messages that may create
;				huge outputs.  Your short message will get lost
;				in this output, so use 0.9 instead.
;
;	warning:	If set, the output string is prepended with 'Warning:' .
;			/continue is implied.  Output is suppressed if the
;			NV_NO_WARNINGS environent variable is set.
;
;	silent:		Suppressed printing of messages.
;
;	format:		Format string.
;
;
;  OUTPUT: 
;	message:	If /get_message, this keyword will return the last
;			message sent through nv_message.
;
;	get_verbosity:	Returns the current verbosity value.
;
;	test_verbose:   1 if nv_message detects a versbose condition for a 
;			given verbose input, 0 otherwise.
;
;
; ENVIRONMENT VARIABLES:
;	NV_VERBOSITY:	Initial verbosity setting.
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
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro nv_message, string, name=name, anonymous=anonymous, continue=continue, $
             clear=clear, get_message=get_message, format=format, $
             message=_string, explanation=explanation, warning=warning, $
             callback=callback, cb_data_p=cb_data_p, disconnect=disconnect, $
             cb_tag=cb_tag, verbose=verbose, silent=silent, stop=stop, $
             get_verbosity=get_verbosity, test_verbose=test_verbose, exit=exit
common nv_message_block, last_message, cb_tlp, verbosity
@core.include
@nv_block.common

 ;------------------------------------------------
 ; check environment for verbosity override
 ;------------------------------------------------
 if(NOT defined(verbosity)) then $
  begin
   nv_verbosity = getenv('NV_VERBOSITY')
   if(keyword_set(nv_verbosity)) then verbosity = double(nv_verbosity)
  end
 if(NOT keyword_set(verbosity)) then verbosity = 0
 get_verbosity = verbosity

 ;--------------------------------------------------
 ; set verbosity if no string or no test requested
 ;--------------------------------------------------
 verbosity=(n_elements(verbosity) gt 0) ? verbosity : 0
 silence = 1
;;; if(NOT defined(string)) then $
 if((NOT defined(string)) AND (NOT arg_present(test_verbose))) then $
  begin
   if(defined(verbose)) then verbosity = double(verbose[0])
  end $
 ;---------------------------------------------------------------
 ; otherwise test verbosity state
 ;---------------------------------------------------------------
 else if(verbosity GT 0) then $
  begin
   if(NOT defined(verbose)) then silence = 0 $
   else if(verbose LE verbosity) then silence = 0
  end $
 else if(NOT defined(verbose)) then silence = 0

 if(keyword_set(silent)) then verbose = 0
 test_verbose = 1-silence
 if(defined(verbose)) then continue = 1

 ;---------------------------------------------------------------
 ; always print message if execution is stopped
 ;---------------------------------------------------------------
 if(keyword_set(stop) OR (NOT keyword_set(continue))) then silence = 0


 ;------------------------------------------------
 ; manage callbacks
 ;------------------------------------------------
 if(keyword_set(cb_tag)) then $
  begin
   if(keyword_set(disconnect)) then tag_list_rm, cb_tlp, cb_tag $
   else $
    begin
     data_p = nv_ptr_new()
     if(keyword_set(cb_data_p)) then data_p = cb_data_p
     data = {callback:callback, data_p:data_p}
     tag_list_set, cb_tlp, cb_tag, data
    end
   return
  end

 ;--------------------------------------------------
 ; make sure stored message has a defined value
 ;--------------------------------------------------
 if(NOT keyword_set(last_message)) then last_message = ''

 ;--------------------------------------------------
 ; if /clear, just discard last message
 ;--------------------------------------------------
 if(keyword_set(clear)) then $
  begin
   last_message = ''
   return
  end

 ;--------------------------------------------------
 ; if /get_message, just return with last message
 ;--------------------------------------------------
 if(keyword_set(get_message)) then $
  begin
   _string = last_message
   return
  end

 ;---------------------------------------------------------------
 ; otherwise, store last message and print to terminal
 ;---------------------------------------------------------------
 if(NOT keyword_set(string)) then return
 if(keyword_set(warning)) then $
  begin
   if(keyword_set(getenv('NV_NO_WARNINGS'))) then silence = 1
   continue = 1
   string = '[WARNING] ' + string
  end

; last_message = string

 if(NOT keyword_set(anonymous)) then $
  if(NOT keyword_set(name)) then $
   begin
    help, /traceback, output=trace
    p = strpos(trace, '%')
    w = where(p EQ 0)
    line = strcompress(trace[w[1]])
    ss = parse_comma_list(line, delim=' ')
    name = ss[1]
   end

 if(keyword_set(name)) then string = strupcase(name)+': ' + string



 if((NOT silence) AND (NOT ptr_valid(cb_tlp))) then $
  begin
;   message, string, /continue, /noname
   print, string, format=format

   if(keyword_set(explanation)) then print, '	' + explanation
   last_message = string
  end
 if(keyword_set(stop)) then stop
 if(keyword_set(exit)) then exit
 if(NOT keyword_set(continue)) then retall


 ;----------------------------------------------------
 ; call callbacks
 ;----------------------------------------------------
 if(ptr_valid(cb_tlp)) then $
  begin
   list = *cb_tlp
   n = n_elements(list)
   for i=0, n-1 do $
    begin
     data = tag_list_get(cb_tlp, index=i)
     call_procedure, data.callback, data.data_p, string
    end
  end


end
;===========================================================================
