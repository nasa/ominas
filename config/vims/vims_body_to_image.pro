function vims_body_to_image,cd,bx,v
compile_opt idl2,logical_predicate

	   inertial = bod_body_to_inertial_pos(bx, v)
	   bodinertials=vims_inertial_to_body_pos(cd, inertial)
	   focals=list()
	   rimages=list()
	   foreach bodi,bodinertials do begin
	     focal=cam_body_to_focal(cd,bodi)
	     focals.add,focal
	     rimages.add,cam_focal_to_image(cd,focal)
	   endforeach
	   bodinertial=bod_inertial_to_body_pos(cd, inertial)
	   focal=cam_body_to_focal(cd,bodinertial)
	   rimage=cam_focal_to_image(cd,focal)
	   fnd=*(cam_fn_data_p(cd))
     inds=fnd.inds
     
	   foreach rimag,rimages,ri do begin
	     dists=reform((rimag[0,*]-inds[0,ri])^2+(rimag[1,*]-inds[1,ri])^2)
	     if ~n_elements(mindis) then begin
	       mindis=dists
	       mininds=replicate(ri,n_elements(dists))
	     endif else begin
	       w=where(dists lt mindis,count)
	       if count then begin
	         mindis[w]=dists[w]
	         mininds[w]=ri
	       endif
	     endelse
	   endforeach
	   rimag=rimages.toarray()
	   ret=rimage
	   for i=0,n_elements(dists)-1 do ret[*,i]=rimag[mininds[i],*,i]
	   
return,ret
end
