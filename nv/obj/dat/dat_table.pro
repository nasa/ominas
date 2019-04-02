;=============================================================================
;+
; NAME:
;	dat_table
;
;
; PURPOSE:
;	Returns a readable version of the specified table.  
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	table = dat_table(dd, </translators, /transforms, /io>)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	translators:	If set, the translators table is returned.
;
;	transforms:	If set, the transforms table is returned.
;
;	io:		If set, the I/O table is returned.
;
;	format:		Format code for function names.
;
;	indent:		Table indentation; default is 1.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	String array with the table
;
;
; STATUS: Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale8/2018
;	
;-
;=============================================================================



;=============================================================================
; dtb_blanks
;
;=============================================================================
pro dtb_blanks, s
 w = where(s EQ '')
 if(w[0] NE -1) then s[w] = '-'
end
;=============================================================================



;=============================================================================
; dat_table
;
;=============================================================================
function dat_table, dd, noevent=noevent, format=format, indent=indent, $
                 translators=translators, transforms=transforms, io=io
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 if(NOT defined(indent)) then indent = 1
 left = str_pad(' ', indent)

 ;-------------------------------------------------
 ; translators table
 ;-------------------------------------------------
 if(keyword_set(translators)) then $
  begin
   if(NOT keyword_set(format)) then format = '(A-27)'

   input_fns = *_dd.input_translators_p
   output_fns = *_dd.output_translators_p
   keyword_fns = strarr(n_elements(input_fns))

   if(keyword_set(*_dd.tr_keyvals_p)) then $
    begin
     keywords_p = *(*_dd.tr_keyvals_p).keywords_p
     values_p = *(*_dd.tr_keyvals_p).values_p
    end
  end

 ;-------------------------------------------------
 ; transforms table
 ;-------------------------------------------------
 if(keyword_set(transforms)) then $
  begin
   if(NOT keyword_set(format)) then format = '(A-27)'

   input_fns = *_dd.input_transforms_p
   output_fns = *_dd.output_transforms_p
   keyword_fns = strarr(n_elements(input_fns))

   if(keyword_set(*_dd.tf_keyvals_p)) then $
    begin
     keywords_p = *(*_dd.tf_keyvals_p).keywords_p
     values_p = *(*_dd.tf_keyvals_p).values_p
    end
  end

 ;-------------------------------------------------
 ; I/O table
 ;-------------------------------------------------
 if(keyword_set(io)) then $
  begin
   if(NOT keyword_set(format)) then format = '(A-18)'

   input_fns = _dd.input_fn
   output_fns = _dd.output_fn
   keyword_fns = _dd.keyword_fn

   if(keyword_set(*_dd.io_keyvals_p)) then $
    begin
     keywords_p = *(*_dd.io_keyvals_p).keywords_p
     values_p = *(*_dd.io_keyvals_p).values_p
    end
  end


 ;-------------------------------------------------
 ; build output table
 ;-------------------------------------------------
 dtb_blanks, input_fns
 dtb_blanks, output_fns

 n = n_elements(input_fns)
 for i=0, n-1 do $
  begin
   input_fn = input_fns[i]
   output_fn = output_fns[i]
   keyword_fn = keyword_fns[i]

   keyvals = ''
   if(keyword_set(keywords_p)) then $
    if(ptr_valid(keywords_p[i])) then $
      begin
       keywords = *keywords_p[i]
       values = *values_p[i]
       keyvals = keywords + '=' + values
       nkv = n_elements(keyvals)

       input_fn = strarr(nkv) & input_fn[0] = input_fns[i]
       output_fn = strarr(nkv) & output_fn[0] = output_fns[i]
      end

   dtb_blanks, keyvals

   line = left + string(input_fn, format=format) + ' ' $
                  + string(output_fn, format=format) + ' ' 

   if(keyword_set(keyword_fn)) then $
          line = line + string(keyword_fn, format=format) + ' '

   line = line + keyvals
  
   table = append_array(table, line)
  end

 return, table
end
;===========================================================================



