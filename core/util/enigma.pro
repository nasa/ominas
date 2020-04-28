;==============================================================================
; enig_advance
;
;==============================================================================
pro enig_advance, settings

 n_rotors = n_elements(settings)

 i = -1
 repeat $
  begin
   i = i + 1
   settings[i] = byte(settings[i] + 1)
  endrep until(settings[i] NE 0) 

end
;==============================================================================



;==============================================================================
; enig_rotor
;
;==============================================================================
function enig_rotor, setting, input, _rotor_num

 seed = double(byte(setting + input))
 rotor_num = double(_rotor_num)
 seed = seed + 256d*rotor_num

 output = byte(randomu(seed) * 255b)

 return, output
end
;==============================================================================



;==============================================================================
; enig_encode
;
;==============================================================================
function enig_encode, settings, input

 n_rotors = n_elements(settings)

 x = input
 for i=0, n_rotors-1 do x = enig_rotor(settings[i], x, i)
 output = x
 enig_advance, settings

 return, output
end
;==============================================================================



;==============================================================================
; enigma
;
;  Settings is a byte array, message is a string.
;  The number of rotors is determined by the number of rotor settings given.
;
;==============================================================================
function enigma, _settings, message

 settings = _settings

 inputs = byte(message)
 n = n_elements(inputs)
 outputs = bytarr(n)

 for i=0, n-1 do outputs[i] = enig_encode(settings, inputs[i])

 result = string(outputs)

 return, result
end
;==============================================================================
