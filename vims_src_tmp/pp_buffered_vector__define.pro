; docformat = 'rst'
;+
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Sep/2009
;-

;+
; :Description:
;    Creates a pp_buffered_vector object, with the contents of the given array, or empty
;    if it is not provided.
;    The buffered vector can contain elements of any type. The type is determined by the type of
;    the first element put into it (if not at initialization, at the first append operation).
;
; :Params:
;    initvec : in, optional
;      An array whose elements are to be placed in the object on creation.
;
; :Keywords:
;    buffersize : in, optional, default=100
;      Size of the step to use when incrementing the number of elements contained by the object.
;
; :Examples:
;    See the example in pp_bufferedvector__define.
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_buffered_vector::init,initvec,buffersize=buffersize
compile_opt idl2,hidden

;Defaults
if (n_elements(buffersize) ne 1) then buffersize=100
ret=0
self.buffersize=buffersize
;If an initializer is provided, put its elements into the vector
self.count=n_elements(initvec)
if (self.count gt 0) then begin
  self.size=buffersize*ceil(double(self.count)/buffersize)
  self.data=ptr_new(replicate(initvec[0],self.size))
  (*self.data)[0]=reform(initvec,self.count)
endif
ret=1
return,ret
end

;+
; :Hidden:
;-
pro pp_buffered_vector::cleanup
compile_opt idl2,hidden
;Clear the heap variable that contained the data
ptr_free,self.data
end

;+
; :Description:
;    Adds the given data (scalar or array) to the end of the buffered vector, expanding
;    its allocated size if necessary.
;
; :Params:
;    data : in, required
;      The scalar or array to be put at the end of the buffered vector.
;
; :Examples:
;    See the example in pp_bufferedvector__define.
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
pro pp_buffered_vector::append,data
compile_opt idl2,hidden
ndata=n_elements(data)
if (ndata eq 0) then return ;If nothing to add
;catch,error_status
error_status=0
if (error_status ne 0) then begin
  catch,/cancel
  ;If an error is caught, nothing gets changed and the object is still valid
  if (self.size ne oldsize) then begin ;Undo the resizing if the assignment failed
    self.size=oldsize
    ptr_free,self.data
    self.data=ptr_new(olddata)
  endif
  print,'pp_buffered_vector: Provided data could not be appended' 
endif else begin
  if (self.size ge self.count+ndata) then (*self.data)[self.count]=reform(data,ndata) else begin
;Resizing, if needed
    oldsize=self.size
    self.size=self.buffersize*ceil(double(oldsize+ndata)/self.buffersize)
    if (oldsize gt 0) then begin
      olddata=*self.data
      ptr_free,self.data
      self.data=ptr_new(replicate(olddata[0],self.size))
      (*self.data)[0]=olddata
    endif else self.data=ptr_new(replicate(data[0],self.size))
    (*self.data)[self.count]=reform(data,ndata)
  endelse
  self.count=self.count+ndata
endelse
catch,/cancel
end

;+
; :Description:
;    Retrieves one or more data elements currently stored in the buffered vector.
;
; :Returns:
;    If the buffered vector is empty, returns 0, with a count of 0. Otherwise, returns an array with
;    the selected elements from the buffered vector, and the number of elements in count.
;
; :Params:
;    nget : in, optional, default=1
;      The number of elements to retrieve. If positive, the nget first elements are returned. If
;      negative, the last -nget elements are returned. If abs(nget) is larger than the number of
;      elements in the buffered vector, all the elements are returned. The value returned by count
;      must be checked to find out how many elements were actually returned. 
;
; :Keywords:
;    all : in, optional, default=0
;      If set, all the elements stored in the buffered vector are returned.
;    count : out, optional
;      Returns the number of elements retrieved.
;
; :Examples:
;    See the example in pp_bufferedvector__define. 
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_buffered_vector::getdata,nget,all=all,count=count
compile_opt idl2,hidden

;Defaults
if (n_elements(nget) ne 1) then nget=1
count=0
ret=0
if keyword_set(all) then begin
  if (self.count gt 0) then ret=(*self.data)[0:self.count-1]
  count=self.count
endif else begin
  if (nget lt 0) then begin ;Get the -nget last elements
    count=(-nget)<self.count
    ret=(*self.data)[self.count-count:self.count-1]
  endif else if (nget gt 0) then begin ;Get the nget first elements
    count=nget<self.count
    ret=(*self.data)[0:count-1]
  endif
endelse
return,ret
end

;+
; :Description:
;    Returns the number of elements currently stored in the buffered vector.
;
; :Examples:
;    See the example in pp_bufferedvector__define. 
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_buffered_vector::getcount
compile_opt idl2,hidden
return,self.count
end
;+
; :Description:
;    Returns the currently allocated length for the buffered vector.
;
; :Examples:
;    See the example in pp_bufferedvector__define. 
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_buffered_vector::getsize
compile_opt idl2,hidden
return,self.size
end
;+
; :Description:
;    Returns the step by which the buffered vector is incremented when necessary.
;
; :Examples:
;    See the example in pp_bufferedvector__define. 
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_buffered_vector::getbuffersize
compile_opt idl2
return,self.buffersize
end

;+
; :Description:
;   Object to keep an adjustable length vector, using a buffer to decrease the frequency of resizing
;
;   It is a simple (without DLM) and relatively efficient implementation of a container similar to a list,
;   intended for light use. For heavy use, it would take a DLM to implement a proper list.
;    
; :Examples:
;   Make a new empty buffered vector:: 
; 
;     a=obj_new('pp_buffered_vector')
;     print,a->getcount()
;     ;0
;     a->append,indgen(10)
;     print,a->getcount()
;     ;10
;     print,a->getdata(5)
;     ;0       1       2       3       4
;     rint,a->getdata(-5)
;     ;5       6       7       8       9
;     print,a->getdata(/all)
;     ;0       1       2       3       4       5       6       7       8       9
;     print,a->getsize()
;     ;100
;     print,a->getbuffersize()
;     ;100
;     obj_destroy,a
;
; :Uses:
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Sep/2009
;-
pro pp_buffered_vector__define
compile_opt idl2
;Object to keep an adjustable length vector, using a buffer to decrease the frequency of resizing
;It is a simple and relatively efficient implementation of a container similar to a list
void={pp_buffered_vector,count:0L,data:ptr_new(),buffersize:0L,size:0L}
end
