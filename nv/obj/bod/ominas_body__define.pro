;=============================================================================
; ominas_body::init
;
;=============================================================================
function ominas_body::init, _ii, crd=crd0, bd=bd0, $
@bod__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(bd0)) then struct_assign, bd0, self
 void = self->ominas_core::init(ii, crd=crd0, $
@cor__keywords.include
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
 self.abbrev = 'BOD'
 self.tag = 'BD'

 self.opaque = 1
 if(defined(opaque)) then self.opaque = decrapify(opaque[ii])
 if(keyword_set(time)) then self.time = decrapify(time[ii])
 if(keyword_set(pos)) then self.pos = pos[*,*,ii]
 if(keyword_set(vel)) then self.vel[0:(size(vel))[1]-1,*] = vel[*,*,ii]
 if(keyword_set(avel)) then self.avel[0:(size(avel))[1]-1,*] = avel[*,*,ii]
 if(keyword_set(libv)) then self.libv[0:(size(libv))[1]-1,*] = libv[*,*,ii]
 if(keyword_set(dlibdt)) then self.dlibdt[0:(size(dlibdt))[1]-1] = dlibdt[*,ii]
 if(keyword_set(lib)) then self.lib[0:(size(lib))[1]-1] = lib[*,ii]

 if(NOT keyword_set(orient)) then self.orient = idgen(3) $
 else self.orient = orient[*,*,ii]

 if(keyword_set(fn_body_to_inertial)) then $
                        self.fn_body_to_inertial=decrapify(fn_body_to_inertial[ii]) $
 else self.fn_body_to_inertial = decrapify('bod_body_to_inertial_default')
 if(keyword_set(fn_inertial_to_body)) then $
                          self.fn_inertial_to_body=decrapify(fn_inertial_to_body[ii]) $
 else self.fn_inertial_to_body = decrapify('bod_inertial_to_body_default')
;;; if(keyword_set(ib_data)) then bod_set_ib_data, bd0, ib_data, /noevent

 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_body__define
;
;
; PURPOSE:
;	Class structure for the BODY class.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	opaque:	Flag describing whether a body is "easily visible".  
;
;		Methods: bod_opaque, bod_set_opaque
;
;
;	time:	Time, at body position, at which this descriptor is valid.
;
;		Methods: bod_time, bod_set_time
;
;
;	orient:	Orientation matrix, transforms body to inertial.
;
;		Methods: bod_orient, bod_set_orient
;
;
;	avel:	Angular velocity vector.  Each higher-order vector is the 
;		angular velocity for the vector of the preceding order.
;
;		Methods: bod_avel, bod_set_avel
;
;
;	pos:	Position of body center in the inertial frame.
;
;		Methods: bod_pos, bod_set_pos
;
;
;	vel:	Velocity of body center in the inertial frame.
;
;		Methods: bod_vel, bod_set_vel
;
;
;	libv:	Libration vector.  Each higher-order vector is the libration 
;		for the vector of the preceding order.  The body librates about
;		the direction v_unit(libv), with an amplitude given by 
;		v_mag(libv).
;
;		Methods: bod_libv, bod_set_libv
;
;
;	lib:	Phase of the libraton vectors at body time.  
;
;		Methods: bod_lib, bod_set_lib
;
;
;	dlibdt:	Frequency for each libration vector.
;
;		Methods: bod_dlibdt, bod_set_dlibdt
;
;	aberration:
;		Aberration flag mask: 1=correction performed.
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
pro ominas_body__define

 ndv = bod_ndv()

 struct = $
    { ominas_body, inherits ominas_core, $
	opaque:		 0b, $			; If set, then this body is
						;  "easily visible".
	time:		 double(0), $		; time at which this descriptor
						; is valid at body position
	orient:		 dblarr(3,3), $		; transforms body->inertial

	avel:		 dblarr(ndv,3), $	; angular velocites -- each
						;  higher-order avel is the
						;  ang. vel. for the avel of
						;  the preceding order.
	aberration:	0l, $			; Aberration flag mask: 1=
						;  correction performed

	fn_body_to_inertial:   '', $		; user procedures to tranform
	fn_inertial_to_body:   '', $		;  between body and inertial
						;  vectors

	; note -- body libration currently disabled; see _bod_evolve
	libv:		 dblarr(ndv,3), $	; libration vectors -- each 
						;  higher-order libv is the
						;  libration for the libv of
						;  the preceding order.  Magnitude
						;  gives the amplitude.
	lib:		 dblarr(ndv), $		; libration phase
	dlibdt:		 dblarr(ndv), $		; libration frequency

	pos:		 dblarr(1,3), $		; position of body center
	vel:		 dblarr(ndv,3) $	; velocity and derivatives

    }

end
;===========================================================================



