;=============================================================================
;+
; NAME:
;	read_vicar
;
;
; PURPOSE:
;	Reads a vicar data file.
;
;
; CATEGORY:
;	UTIL/VIC
;
;
; CALLING SEQUENCE:
;	data = read_vicar(filename, label)
;
;
; ARGUMENTS:
;  INPUT:
;	filename:	String giving the name of the file to be read.
;
;  OUTPUT:
;	label:		Named variable in which the vicar label will be
;			returned.
;
;
; KEYWORDS:
;  INPUT:
;	n_l:	If set, this will override the number of lines given by the 
;		'NL' field of the label.	
;
;	n_s:	If set, this will override the number of samples given by the 
;		'NS' field of the label.
;
;	n_b:	If set, this will override the number of bands given by the 
;		'NB' field of the label.
;
;	nlb:	If set, this will override the number of binary header records
;		given by the 'NLB' field of the label.
;
;	nbb:	If set, this will override the number of binary prefix bytes
;		given by the 'NBB' field of the label.
;
;	silent:	If set, no messages are printed.
;
;	swap:	If set, the data array will be byte-swapped.  If not set,
;		then read_vicar will automatically determine whether 
;		to byte swapping is necessary.
;
;	flip:	If set, the data array will be subjected to a rotate(data, 7),
;		i.e., if its an image, it will be flipped vertically.
;
;	default_format:	Data format to use if not given in the label.
;			choices are 'BYTE', 'HALF', 'FULL", 'REAL', and
;			'DOUB'.  default is 'BYTE'.
;
;       bpa:    Binary Prefix Array.  The caller must ensure that this array
;		has appropriate dimensions.
;
;	bha:	Binary Header Array.  The caller must ensure that this array
;		has appropriate dimensions.
;
;  OUTPUT:
;	status:	If no errors occur, status will be zero, otherwise
;		it will be a string giving an error message.
;
;
; RETURN:
;	The data array read from the file.
;
;
; RESTRICTIONS:
;	This program only works with band-sequential data.  If EOL present,
;	the EOL variable is returned as 0, the second LBLSIZE is erased
;	and the first LBLSIZE is adjusted to appear as if the label was
;	not split in two.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	write_vicar
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/1995
;                       Dyer Lytle, 8/1999
;			Vance Haemmerle, 9/1999
;
;       EOL support:    Vance Haemmerle, 6/2000
;	
;-
;=============================================================================

;===========================================================================
; rvc_pl_suffix
;
;===========================================================================
function rvc_pl_suffix, n
 if(n NE 1) then return, 's'
 return, ''
end
;===========================================================================



;===========================================================================
; rvc_strip_quotes
;
;===========================================================================
function rvc_strip_quotes, s

 t=strtrim(s,2)
 
 if(strmid(t, 0, 1) EQ "'") then t=strmid(t, 1, strlen(t)-1)
 if(strmid(t, strlen(t)-1, 1) EQ "'") then t=strmid(t, 0, strlen(t)-1)

 return, t
end
;===========================================================================



;===========================================================================
; read_vicar
;
;===========================================================================
function read_vicar, filename, label, status=status, $
   silent=silent, default_format=default_format, swap=swap, $
   n_l=n_l, n_s=n_s, n_b=n_b, nlb=nlb, nbb=nbb, show=show, flip=flip, $
   bpa=bpa, bha=bha, nodata=_nodata, get_nl=nl, get_ns=ns, get_nb=nb, type=type

 nodata = keyword_set(_nodata)

 if(n_elements(n_l) NE 0) then nl=n_l
 if(n_elements(n_s) NE 0) then ns=n_s
 if(n_elements(n_b) NE 0) then nb=n_b

 if(NOT keyword_set(default_format)) then default_format='BYTE'

 status=0

;----------------open file------------------

 openr, unit, filename, /get_lun, error=error
 if(error NE 0) then $
  begin
   status=!err_string
   if(NOT keyword_set(silent)) then message, status
   return, 0
  end


;---------------read label size----------------

 records=assoc(unit, bytarr(30, /nozero))
 record=records(0)
 str=string(record)

 label_nbytes=vicgetpar(str, 'LBLSIZE', status=status)
 if(keyword_set(status)) then $
  begin
   if(NOT keyword_set(silent)) then message, status
   close, unit
   free_lun, unit
   return, 0
  end

 dat = fstat(unit)
 label_nbytes = label_nbytes < dat.size


;-----------------get label-------------------

 label_records=assoc(unit, bytarr(label_nbytes, /nozero))
 label=string(label_records(0))


;-----------------get label info -------------

 eol=vicgetpar(label, 'EOL', status=status)
 if(eol eq 1 and NOT keyword_set(silent)) then $
   print, 'End of File label indicated'
 recsize=vicgetpar(label, 'RECSIZE', status=status)
 if(keyword_set(status)) then $
  begin
   if(NOT keyword_set(silent)) then message, status
   close, unit
   free_lun, unit
   return, 0
  end


;------------get image dimensions-------------

 nl_note=''
 if(n_elements(nl) EQ 0) then $
  begin
   nl=long(vicgetpar(label, 'NL', status=status))
   if(keyword_set(status)) then $
    begin
     if(NOT keyword_set(silent)) then message, status
     close, unit
     free_lun, unit
     return, 0
    end
  end else nl_note=' (forced)'

 ns_note=''
 if(n_elements(ns) EQ 0) then $
  begin
   ns=long(vicgetpar(label, 'NS', status=status))
   if(keyword_set(status)) then $
    begin
     if(NOT keyword_set(silent)) then message, status
     close, unit
     free_lun, unit
     return, 0
    end
  end else ns_note=' (forced)'

 nb_note=''
 if(n_elements(nb) EQ 0) then $
  begin
   nb=long(vicgetpar(label, 'NB', status=status))
   if(keyword_set(status)) then $
    begin
     nb=1
     nb_note=' (by default)'
    end
  end else nb_note=' (forced)'

 nlb_note=''
 if(n_elements(nlb) EQ 0) then $
  begin
   nlb=long(vicgetpar(label, 'NLB', status=status))
   if(keyword_set(status)) then nlb_note=' (by default)'
  end else nlb_note=' (forced)'

 nbb_note=''
 if(n_elements(nbb) EQ 0) then $
  begin
   nbb=long(vicgetpar(label, 'NBB', status=status))
   if(keyword_set(status)) then $
    begin
     nbb=200
     nbb_note=' (by default)'
    end
  end else nbb_note=' (forced)'


 if(NOT keyword_set(silent)) then $
  begin
   print,'NL = '+strtrim(nl,2)+' line'+rvc_pl_suffix(nl)+nl_note
   print,'NS = '+strtrim(ns,2)+' sample'+rvc_pl_suffix(ns)+ns_note
   print,'NB = '+strtrim(nb,2)+' band'+rvc_pl_suffix(nb)+nb_note
   print,'NLB= '+strtrim(nlb,2)+$
                           ' binary header record'+rvc_pl_suffix(nlb)+nlb_note
   print,'NBB= '+strtrim(nbb,2)+$
                             ' binary prefix byte'+rvc_pl_suffix(nbb)+nbb_note
  end


;-----------------get data format------------------

 format_note = ''
 format = vicgetpar(label, 'FORMAT', status=status)
 if(keyword_set(status)) then $
  begin
   format_note=' (by default)'
   if(keyword_set(default_format)) then format=default_format $
   else $
    begin
     if(NOT keyword_set(silent)) then message, status
     close, unit
     free_lun, unit
     return, 0
    end
  end

 format = rvc_strip_quotes(strupcase(format))


;------set up arrays for the appropriate data format-------

 case format of
  'BYTE' : $
	   begin
	    type = 1
            elm_size=1l
           end

  'HALF' :  $
	   begin
	    type = 2
            elm_size=2l
           end

  'FULL' : $
	   begin
	    type = 3
            elm_size=4l
           end

  'REAL' :  $
	   begin
	    type = 4
            elm_size=4l
           end

  'DOUB' :  $
	   begin
	    type = 5
            elm_size=8l
           end

  else : $
      begin
       status='Unrecognized data format : '+format+'.'
       if(NOT keyword_set(silent)) then message, status
       close, unit
       free_lun, unit
       return, 0
      end
 endcase

 if(NOT keyword_set(silent)) then $
                         print, 'Data format is '+format+'.'+format_note


 bh_size = ((ns*elm_size)+nbb)*nlb
 data_size = nl*ns*nb*elm_size + nbb*nl*nb

 ;------------------------------------------------------
 ; force /nodata if filesize suggests there is no data
 ;------------------------------------------------------
 fs = fstat(unit)

 if(fs.size LE fs.cur_ptr) then nodata = 1
; frac = float(data_size) / float(fs.size)
; if((frac LT 0.9) OR (frac GT 1.1)) then nodata = 1

 if(keyword_set(nodata)) then $
              if(NOT keyword_set(silent)) then print, 'Not reading image data.' 

 image = 0
 if(NOT keyword_set(nodata)) then $
  begin
   line = make_array(ns, /nozero, type=type)
   image = make_array(ns, nl, nb, /nozero, type=type)

;-----------------read the image---------------------

   if(nbb NE 0) then bptemp = bytarr(nbb)
   if(nbb NE 0) then binary_prefix = bytarr(nbb,nl)

   if(nlb NE 0) then $
    begin
     binary_header = bytarr(bh_size)
     readu, unit, binary_header 
     bha = binary_header
    end

   j=0l
   while(j LT nb) do $
    begin
     i=0l
     while(i LT nl) do $
      begin
       if(nbb NE 0) then $
        begin
         readu, unit, bptemp
         binary_prefix[*,i] = bptemp
        end
       readu, unit, line
       image[*,i,j] = line
       i = i + 1
      end
     j = j + 1
    end

  if(nbb NE 0) then bpa = binary_prefix


;----------determine whether byte-swapping is necessary-----------

   a=1
   byteorder, a, /ntohs
   if(a EQ 1) then endian='big' else endian='little'

   intfmt=vicgetpar(label, 'INTFMT', status=status)

   proceed = 0
   if(keyword_set(status)) then proceed = 1 $
   else if((intfmt NE 'LOW' AND intfmt NE 'HIGH')) then proceed = 1

   if proceed then begin
     if NOT keyword_set(silent) then begin
       print, 'Unrecognized value of integer format (endian):'
       print, '     INTFMT = '+intfmt
       print, 'No byte-swapping performed.'
     endif
   endif $
   else $
    begin

     if endian EQ 'big' AND intfmt EQ 'LOW' AND format NE 'BYTE' then swap=1
     if endian EQ 'little' AND intfmt EQ 'HIGH' AND format NE 'BYTE' then swap=1
    end

;----------determine whether need to convert from VAX float format-----------

   if(format EQ 'REAL' OR format EQ 'DOUB') then begin 
     realfmt=vicgetpar(label, 'REALFMT', status=status)
     if(NOT keyword_set(realfmt)) then realfmt = 'VAX'

;     if(keyword_set(status)) then $
;      begin
;       if(NOT keyword_set(silent)) then $
;                 print, 'Float format unknown.  No corrections performed.'
;      end $
;     else $
;      begin
       if(realfmt EQ 'VAX' AND !version.os NE 'vms') then $
         if(!version.release GT '5.0.3') then vaxconv = 1 $
         else print, 'Need IDL version 5.1 or above to convert from VAX float'
       if(realfmt EQ 'VAX' AND !version.os EQ 'vms' AND $
         !version.release GT '5.0.3') then vaxconv = 1 ; Alpha vms 5.1+ is RIEEE
;      end
   endif

;----------take care of any necessary byte-swapping-----------

   if keyword_set(vaxconv) then begin
     if NOT keyword_set(silent) then print, 'Converting from VAX format...'
     if format EQ 'REAL' then byteorder, image, /vaxtof $
     else if format EQ 'DOUB' then byteorder, image, /vaxtod
   endif else begin
     if keyword_set(swap) then begin
       image = swap_endian(image)
       if NOT keyword_set(silent) then print, $
                                       'Byte swapping has been performed.'
     endif
   endelse

;----------------flip if necessary---------------

   if(keyword_set(flip)) then image=rotate(image, 7)

  end $
 else $
  begin
   point_lun, -unit, pos
   point_lun, unit, pos + bh_size + data_size
  end


;-----------------read eol label--------------

 if(eol eq 1) then $
  begin
   eol_record=bytarr(recsize, /nozero)
   readu, unit, eol_record
   eol_label=string(eol_record)
   eol_nbytes=vicgetpar(eol_label, 'LBLSIZE', status=status)
   if(keyword_set(status)) then $
    if(NOT keyword_set(silent)) then message, status 
   if(eol_nbytes ne 0) then $
    begin
     if(eol_nbytes ne recsize) then $
      begin
       nrecords=eol_nbytes/recsize
       for i=0,nrecords-2 do $
        begin
         readu, unit, eol_record
         eol_label=eol_label+string(eol_record)
        end
      end
     start=strpos(eol_label, 'LBLSIZE')
     eol_label=strmid(eol_label,start,strlen(eol_label)-start)
     start=strpos(eol_label, ' ')
     eol_label=strmid(eol_label,start,strlen(eol_label)-start)
     label = label + eol_label
     vicsetpar, label, 'EOL', 0
     vicsetpar, label, 'LBLSIZE', label_nbytes+eol_nbytes, pad=22
    end
  end


;------------------clean up-------------------

 close, unit
 free_lun, unit


 return, image
end
;===========================================================================
