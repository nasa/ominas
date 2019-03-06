;===========================================================================
; detect_vgr_iss.pro
;
;===========================================================================
function detect_vgr_iss, dd

 label = (dat_header(dd))[0]
 if(NOT keyword_set(label)) then return, ''

 ;---------------------------------
 ; get sublabels
 ;---------------------------------
 meta = dat_header_info(dd, instrument='VGR1_ISS_NA')
 if(NOT keyword_set(meta)) then return, ''
 lab02 = meta.lab02
 lab03 = meta.lab03
 lab07 = meta.lab07

 ;---------------------------------
 ; determine which spacecraft
 ;---------------------------------
 if(strpos(lab02, 'VGR-1') NE -1) then string='VGR1' $
 else if(strpos(lab02, 'VGR-2') NE -1) then string='VGR2' $
 else return, ''

 ;---------------------------------
 ; determine which camera
 ;---------------------------------
 if(strpos(lab03, 'NA CAMERA') NE -1) then string=string+'_ISS_NA' $
 else if(strpos(lab03, 'WA CAMERA') NE -1) then string=string+'_ISS_WA' $
 else if(strpos(lab07, 'NAONLY') NE -1) then string=string+'_ISS_NA' $
 else if(strpos(lab07, 'WAONLY') NE -1) then string=string+'_ISS_WA' $
 else return, ''


 return, string
end
;===========================================================================



;===========================================================================
; detect_vgr_iss.pro
;
;===========================================================================
function __detect_vgr_iss, dd

 label = (dat_header(dd))[0]
 file_type = dat_filetype(dd)

 ;---------------------------------
 ; get sublabels
 ;---------------------------------
 if (file_type EQ 'W10N_PDS') then begin
    jlabel = json_parse(label, /tostruct)
    lab02 = jlabel.task[0].lab02
    lab03 = jlabel.task[0].lab03
    lab07 = jlabel.task[0].lab07
 endif else begin 
    lab02 = vicgetpar(label, 'LAB02')
    lab03 = vicgetpar(label, 'LAB03')
    lab07 = vicgetpar(label, 'LAB07')
 endelse

 ;---------------------------------
 ; determine which spacecraft
 ;---------------------------------
 if(strpos(lab02, 'VGR-1') NE -1) then string='VGR1' $
 else if(strpos(lab02, 'VGR-2') NE -1) then string='VGR2' $
 else return, ''

 ;---------------------------------
 ; determine which camera
 ;---------------------------------
 if(strpos(lab03, 'NA CAMERA') NE -1) then string=string+'_ISS_NA' $
 else if(strpos(lab03, 'WA CAMERA') NE -1) then string=string+'_ISS_WA' $
 else if(strpos(lab07, 'NAONLY') NE -1) then string=string+'_ISS_NA' $
 else if(strpos(lab07, 'WAONLY') NE -1) then string=string+'_ISS_WA' $
 else return, ''


 return, string
end
;===========================================================================
