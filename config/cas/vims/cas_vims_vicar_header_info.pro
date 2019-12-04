;===========================================================================
; cas_vims_vicar_header_info
;
;===========================================================================
function cas_vims_vicar_header_info, dd

  compile_opt idl2

  ndd = n_elements(dd)

  time = dblarr(ndd)
  exposure = dblarr(ndd)
  size = make_array(2,ndd, val=1024)
  filters = strarr((dat_dim(dd[0]))[2],ndd)
  target = strarr(ndd)
  oaxis = dblarr(2,ndd)

  for i=0, ndd-1 do $
    begin
    label = dat_header(dd[i])
    llabel=strsplit(label,string(10B),/extract)
    if(keyword_set(label)) then $
      begin
      ttime=cas_vims_spice_time(label,dt=dt,status=status,startjd=startjd,endjd=endjd)
      ;-----------------------------------
      ; time
      ;-----------------------------------
      if(NOT keyword_set(_time)) then begin
        time[i]=spice_str2et(ttime)+dt
      endif

      ;-----------------------------------
      ; exposure time
      ;-----------------------------------
      exposure[i] = 2d0*dt

      ;-----------------------------------
      ; image size
      ;-----------------------------------
      size[1,i] = fix(pp_get_label_value(label,'SWATH_LENGTH'))
      size[0,i] = fix(pp_get_label_value(label,'SWATH_WIDTH'))

      ;-----------------------------------
      ; optic axis
      ;-----------------------------------
      oaxis[0,i]=(size[0,i]-1d0)/2d0-3d0
      oaxis[1,i]=(size[1,i]-1d0)/2d0+3d0

      ;-----------------------------------
      ; filters
      ;-----------------------------------
      filters[*,i] = pp_getcubeheadervalue(llabel,'BAND_BIN_CENTER',/not_trimmed)+'_'+pp_getcubeheadervalue(llabel,'BAND_BIN_UNIT',/not_trimmed)

      ;-----------------------------------
      ; target
      ;-----------------------------------
      target_name = strupcase(pp_get_label_value(label, 'TARGET_NAME'))
      target_desc = strupcase(pp_get_label_value(label, 'TARGET_DESC'))
      target[i] = target_name
      obs_id = pp_get_label_value(label, 'OBSERVATION_ID')
      if((strpos(strupcase(obs_id), 'OPNAV'))[0] NE -1) then target[i] = target_desc
    end
  end

  if(NOT keyword_set(_time)) then _time = time


 return, {time: time, $
          endjd: endjd, $
          startjd: startjd, $
          exposure: exposure, $
          size: size, $
          filters: filters, $
          target: target, $
          oaxis: oaxis}
end 
;===========================================================================



