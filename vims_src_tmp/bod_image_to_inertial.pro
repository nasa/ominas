function bod_image_to_inertial,cd,p
compile_opt idl2,logical_predicate

       
             focal=cam_image_to_focal(cd, p)
             body=cam_focal_to_body(cd,focal)
             fn=cam_fn_body_to_inertial(cd)
             if fn then begin
               ret=call_function(fn,cd,body,p)
             endif else begin
               ret=bod_body_to_inertial(cd,body)
             endelse

	   
return,ret
end
