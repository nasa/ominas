;=============================================================================
; spkbug
;
;=============================================================================
pro spkbug

 cspice_furnsh, '/home/spitale/kernels/lsk/naif0010.tls'
 cspice_furnsh, '/home/spitale/kernels/icee/13-F7_extension_scpse.bsp'

 cspice_str2et, '2031 OCT 07 00:00:00.000', et

 cspice_spkgeo, -650, et, 'j2000', 502, sc_state_europa, ltime
 cspice_spkgeo, 502, et, 'j2000', 502, plt_state_europa, ltime

 cspice_spkgeo, -650, et, 'j2000', 0, sc_state_ssb, ltime
 cspice_spkgeo, 502, et, 'j2000', 0, plt_state_ssb, ltime

end
;=============================================================================
