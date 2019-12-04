;===============================================================================
; resize_array
;
;===============================================================================
function resize_array, array, new_dim

 dim = size(array, /dim)
 type = size(array, /type)
 ndim = n_elements(dim)

 new_array = make_array(new_dim, type=type)
 
 case ndim of
  1: new_array[0:(dim[0]<new_dim[0])-1] = array[0:(dim[0]<new_dim[0])-1]
  2: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1]
  3: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1, $
               0:(dim[2]<new_dim[2])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1, $
                            0:(dim[2]<new_dim[2])-1]
  4: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1, $
               0:(dim[2]<new_dim[2])-1, $
               0:(dim[3]<new_dim[3])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1, $
                            0:(dim[2]<new_dim[2])-1, $
                            0:(dim[3]<new_dim[3])-1]
  5: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1, $
               0:(dim[2]<new_dim[2])-1, $
               0:(dim[3]<new_dim[3])-1, $
               0:(dim[4]<new_dim[4])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1, $
                            0:(dim[2]<new_dim[2])-1, $
                            0:(dim[3]<new_dim[3])-1, $
                            0:(dim[4]<new_dim[4])-1]
  6: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1, $
               0:(dim[2]<new_dim[2])-1, $
               0:(dim[3]<new_dim[3])-1, $
               0:(dim[4]<new_dim[4])-1, $
               0:(dim[5]<new_dim[5])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1, $
                            0:(dim[2]<new_dim[2])-1, $
                            0:(dim[3]<new_dim[3])-1, $
                            0:(dim[4]<new_dim[4])-1, $
                            0:(dim[5]<new_dim[5])-1]
  7: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1, $
               0:(dim[2]<new_dim[2])-1, $
               0:(dim[3]<new_dim[3])-1, $
               0:(dim[4]<new_dim[4])-1, $
               0:(dim[5]<new_dim[5])-1, $
               0:(dim[6]<new_dim[6])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1, $
                            0:(dim[2]<new_dim[2])-1, $
                            0:(dim[3]<new_dim[3])-1, $
                            0:(dim[4]<new_dim[4])-1, $
                            0:(dim[5]<new_dim[5])-1, $
                            0:(dim[6]<new_dim[6])-1]
  8: new_array[0:(dim[0]<new_dim[0])-1, $
               0:(dim[1]<new_dim[1])-1, $
               0:(dim[2]<new_dim[2])-1, $
               0:(dim[3]<new_dim[3])-1, $
               0:(dim[4]<new_dim[4])-1, $
               0:(dim[5]<new_dim[5])-1, $
               0:(dim[6]<new_dim[6])-1, $
               0:(dim[7]<new_dim[7])-1] = $
                      array[0:(dim[0]<new_dim[0])-1, $
                            0:(dim[1]<new_dim[1])-1, $
                            0:(dim[2]<new_dim[2])-1, $
                            0:(dim[3]<new_dim[3])-1, $
                            0:(dim[4]<new_dim[4])-1, $
                            0:(dim[5]<new_dim[5])-1, $
                            0:(dim[6]<new_dim[6])-1, $
                            0:(dim[7]<new_dim[7])-1]
 endcase



 return, new_array
end
;===============================================================================
