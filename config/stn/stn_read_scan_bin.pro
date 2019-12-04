;=============================================================================
; stn_read_scan_bin
;
;=============================================================================
function stn_read_scan_bin, dd, header, nodata=nodata, sample=sample
 udata = 0

 filename = dat_filename(dd)

 rad = read_scan_bin(filename, long, time, dn)

 data = [tr(rad), tr(dn)]
 if(keyword__set(time)) then data = [data, tr(time)]
 if(keyword__set(long)) then data = [data, tr(long)]

 return, tr(data)
end
;=============================================================================
