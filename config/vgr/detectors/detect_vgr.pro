;===========================================================================
; detect_vgr.pro
;
;===========================================================================
function detect_vgr, label, udata


 ;---------------------------------
 ; get sublabels
 ;---------------------------------
 lab02 = vicgetpar(label, 'LAB02')
 lab03 = vicgetpar(label, 'LAB03')
 lab07 = vicgetpar(label, 'LAB07')

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
