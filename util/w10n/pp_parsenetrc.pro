; docformat = 'rst rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net`), Aug/2016
;-
;+
; :Description:
;    Parses a `.netrc` file (`https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html <https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html>`) into a hash with usernames and passwords,
;    indexed by machine name.
;
; :Params:
;    file: in, required
;     `.netrc` file to read. If not provided, defaults to `~/.netrc`.
;
;
;
; :Author: Paulo Penteado (`http://www.ppenteado.net`), Aug/2016
;-
function pp_parsenetrc,file
compile_opt idl2,logical_predicate

file=n_elements(file) ? file : '~'+path_sep()+'.netrc'

ret=hash()

lines=pp_readtxt(file)
lines=strtrim(lines,2)
w=where(strlen(lines),count)
if ~count then return,ret
lines=lines[w]
w=where(strpos(lines,'#') ne 0,count)
if ~count then return,ret
lines=lines[w] 
tokens=strsplit(strjoin(lines,string(10B)),' '+string(10B)+string(9B)+string(13B),/extract)
w=where(tokens eq 'machine',count)
if ~count then return,ret
w=[w,n_elements(tokens)]
for iw=0,count-1 do begin
  segment=tokens[w[iw]:w[iw+1]-1]
  if n_elements(segment) lt 6 then continue
  machine=segment[1]
  wl=where(segment eq 'login',count)
  if ((~count) || (wl[-1] gt 5)) then continue
  user=segment[wl[-1]+1]
  wp=where(segment eq 'password',count)
  if ((~count) || (wp[-1] gt 5)) then continue
  pass=segment[wp[-1]+1]
  ret[machine]={user:user,pw:pass}
endfor

return,ret

end
