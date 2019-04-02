;=============================================================================
; ominas_ring::init
;
;=============================================================================
function ominas_ring::init, _ii, crd=crd0, bd=bd0, sld=sld0, dkd=dkd0, rd=rd0, $
@rng__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(rd0)) then struct_assign, rd0, self
 void = self->ominas_disk::init(ii, crd=crd0, bd=bd0, sld=sld0, dkd=dkd0, $
@dsk__keywords_tree.include
end_keywords)


 ;-------------------------------------------------------------------------
 ; Handle index errors: set index to zero and try again.  This allows a 
 ; single input to be applied to multiple objects, via multiple calls to
 ; this method.  In that case, all inputs must be given as single inputs.
 ;-------------------------------------------------------------------------
 catch, error
 if(error NE 0) then $
  begin
   ii = 0
   catch, /cancel
  end

 
 ;---------------------------------------------------------------
 ; assign initial values
 ;---------------------------------------------------------------
 self.abbrev = 'RNG'
 self.tag = 'RD'

; if(keyword__set(desc)) then self.desc = decrapify(desc[ii])
 if(keyword__set(desc)) then rng_set_desc, self, decrapify(desc[ii])

 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_ring__define
;
;
; PURPOSE:
;	Class structure for the RING class.
;
;
; CATEGORY:
;	NV/LIB/RNG
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	desc:	String giving the description of the ring.  Valid values
;		are 'EDGE', 'PEAK', 'TROUGH'.
;
;		Methods: rng_desc, rng_set_desc
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro ominas_ring__define

 struct = $
    { ominas_ring, inherits ominas_disk, $
	desc:			'' $		; 'EDGE', 'PEAK', 'TROUGH'
    }

end
;===========================================================================



