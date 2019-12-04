;=============================================================================
;+
; NAME:
;       gen_spice_read_label
;
;
; PURPOSE:
;       Reads a PDS LBL file for a SPICE kernel file
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       gen_spice_read_label, filename, unit, creation
;
;
; ARGUMENTS:
;  INPUT:
;       filename:	Path of the SPK files
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:		File creation date (string)
;
;
; PROCEDURE:		Adds '.lbl' to input filename
;                       Checks for label file, reads if so
;                       Extracts value of PRODUCT_CREATION_TIME
;
;
; RESTRICTIONS:
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     V. Haemmerle,  Feb. 2017
;	Adapted by:	J. Spitale     Feb. 2017
;
;-
;=============================================================================
function gen_spice_read_label, filename, unit, creation

 creation = ''

 ;-----------------------
 ; read file
 ;-----------------------
 lbl_file = filename + '.lbl'
 lines = read_txt_file(lbl_file)
 
 ;------------------------------
 ; search for creation time
 ;------------------------------
 keywords = str_nnsplit(lines, '=', rem=values)
 w = where(keywords EQ 'PRODUCT_CREATION_TIME')
 if(w[0] NE -1) then $
  begin
   creation = values[w[0]]
   bc = byte(creation)
   w = where(bc EQ 13)
   if(w[0] NE -1) then bc[w] = 32
   creation = strtrim(bc,2)
  end

 return, creation
end
;=============================================================================
