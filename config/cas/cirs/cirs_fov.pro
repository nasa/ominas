function cirs_fov,type,sub=sub,nbx=nbx,nby=nby
compile_opt idl2,logical_predicate



if strlowcase(type) eq 'fp1' then begin

endif else begin
  if keyword_set(sub) then begin
    nbx=n_elements(nbx) ? nbx : 10
    nby=n_elements(nby) ? nby : 10
    box=dblarr(2,nbx*nby,5)
    xp=dindgen(nbx+1)/(nbx)
    yp=dindgen(nby+1)/(nby)
    for ix=0,nbx-1 do begin
      for iy=0,nby-1 do begin
        box[0,ix+nbx*iy,*]=xp[[ix,ix,ix+1,ix+1,ix]]
        box[1,ix+nbx*iy,*]=yp[[iy,iy+1,iy+1,iy,iy]]
      endfor
    endfor
  endif else begin
  nbx=100
  box=dblarr(2,nbx*4)
  box[0,0:nbx-1]=dindgen(nbx)/(nbx-1d0)
  box[1,0:nbx-1]=0d0
  box[0,nbx:2*nbx-1]=1d0
  box[1,nbx:2*nbx-1]=dindgen(nbx)/(nbx-1d0)
  box[0,2*nbx:3*nbx-1]=reverse(dindgen(nbx)/(nbx-1d0))
  box[1,2*nbx:3*nbx-1]=1d0
  box[0,3*nbx:4*nbx-1]=0d0
  box[1,3*nbx:4*nbx-1]=reverse(dindgen(nbx)/(nbx-1d0))
  endelse
endelse
return,box

end
