; docformat = 'rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
;+
; :Description:
;    Converts a number of bytes into a more human-readable form, by expressing it
;    in KB, MB, GB or TB, depending on the value.
;
; :Params:
;    sizes: in, required
;      Number(s) of bytes to be convertedo to KB/MB/GB/TB. Can be scalar or array.
;
; :Keywords:
;    units: out, optional
;      The unit(s) corresponding to each converted size, as strings.
;    strs: out, optional
;      A string version of the output, with the number(s) plus the unit strings.
;    string: in,optional
;      If set, output has string(s) with the converted numbers plus the units.
;      
; :Examples:
; 
;   Convert a few values into strings with units::
;   
;     print,pp_readablesize([1023,1024,2d6,3d9],/string)
;     ; 1023.0000 B 1.0000000 KB 1.9073486 MB 2.7939677 GB
;     
;   Without units appended::
;   
;     print,pp_readablesize([1023,1024,2d6,3d9])
;     ; 1023.0000       1.0000000       1.9073486       2.7939677
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
function pp_readablesize,sizes,units=units,strs=strs,string=string
compile_opt idl2,logical_predicate
ret=dblarr(n_elements(sizes))
units=strarr(n_elements(sizes))
strs=units
foreach sz,sizes,isz do begin
  tmp=alog(double(sz))/alog(2d0)
  case 1 of
    tmp lt 10d0: begin
      szf=1d0
      units[isz]='B'
    end
    (tmp ge 10d0) && (tmp lt 20d0): begin
      szf=2d0^10
      units[isz]='KB'
    end
    (tmp ge 20d0) && (tmp lt 30d0): begin
      szf=2d0^20
      units[isz]='MB'
    end
    (tmp ge 30d0) && (tmp lt 40d0): begin
      szf=2d0^30
      units[isz]='GB'
    end
    else: begin
      szf=2d0^40
      units[isz]='TB'
    end
  endcase
  ret[isz]=double(sz)/szf
  strs[isz]=strtrim(ret[isz],2)+' '+units[isz]  
endforeach
if keyword_set(string) then ret=strs
return,ret
end
