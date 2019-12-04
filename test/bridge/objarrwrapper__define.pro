function objarrwrapper::init,arg1
compile_opt idl2,logical_predicate,hidden
self.objs=list()
return,1
end


function objarrwrapper::_overloadMethod, method, arg1, arg2, _EXTRA=ex
compile_opt idl2,logical_predicate

;based on  IDL wrapper example, https://harrisgeospatial.com/docs/idl_object_overloadmethod.html
  if (ISA(ex)) then begin

    case N_PARAMS()-1 of

    1: result = CALL_FUNCTION(method, arg1, _EXTRA=ex)

    2: result = CALL_FUNCTION(method, arg1, arg2, _EXTRA=ex)

    endcase

  endif else begin

    case N_PARAMS()-1 of

    1: result = CALL_FUNCTION(method, arg1)

    2: result = CALL_FUNCTION(method, arg1, arg2)

    endcase

  endelse

  if isa(result,'objref') then begin
   self.objs=list(result,/extract)
   return,self.objs
  endif

  return, result
end



function objarrwrapper::getpropbyname,name
compile_opt idl2,logical_predicate
print,'eeeeeeeeeeee'
help,name,self
return,1
end

function objarrwrapper::testfunction,arg1
l=list()
l.add,plot(/test,/buffer,name='p1')
l.add,plot(/test,/buffer,name='p2')
return,l
end


pro objarrwrapper__define
compile_opt idl2,logical_predicate,hidden
!null={objarrwrapper,inherits IDL_Object,objs:obj_new()}
end

