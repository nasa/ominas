;=============================================================================
; dh_read_pdscirstable.pro
;
;=============================================================================
function dh_read_pdscirstable, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples
 compile_opt idl2,logical_predicate
 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

 ;--------------------------------------------------------
 ; read label
 ;--------------------------------------------------------
 label = headpds(filename, /silent)

 ;- - - - - - - - - - - - - - - - - - - - -
 ; get rid of CR/LFs included by headpds
 ;- - - - - - - - - - - - - - - - - - - - -
 label = strtrim(str_nnsplit(label, string(13b)), 2)

 ;- - - - - - - - - - - - - - - - - - - - -
 ; determine image dimensions
 ;- - - - - - - - - - - - - - - - - - - - -


dat = readpds(filename, /silent)
 
min=0
max=0




 ;--------------------------------------------------------
 ; read image
 ;--------------------------------------------------------
    wt=where(strmatch(tag_names(dat),'*TABLE',/fold_case),/null)

    table={}
    foreach name,dat.(wt[0]).names,iname do table=create_struct(table,name,(dat.(wt[0]).(iname+1))[0])
    table=create_struct(table,'_ispm',ptr_new())
    table=create_struct(table,'_ispw',ptr_new())
    table=create_struct(table,'_conf_key','')
    table=create_struct(table,'_request','')
    table=replicate(table,n_elements(dat.(wt[0]).column1))
    foreach name,dat.(wt[0]).names,iname do table.(iname)=dat.(wt[0]).(iname+1)

    if total(stregex(label,'^[[:space:]]*OBJECT[[:space:]]*=[[:space:]]*TABLE[[:space:]]*$',/boolean)) then begin
      wi=where(stregex(label,'^[[:space:]]*OBJECT[[:space:]]*=[[:space:]]*FILE[[:space:]]*$',/boolean))
      we=where(stregex(label,'^[[:space:]]*END_OBJECT[[:space:]]*=[[:space:]]*FILE[[:space:]]*$',/boolean))
      foreach w,wi,iw do begin
        seg=label[w:we[iw]]
        if total(stregex(seg,'^[[:space:]]*RECORD_TYPE[[:space:]]*=[[:space:]]*VARIABLE_LENGTH[[:space:]]*$',/boolean)) then begin
          w=where(stregex(seg,'^[[:space:]]*FILE_NAME[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*$',/boolean))
          fname=seg[w]
          fname=stregex(fname,'^[[:space:]]*FILE_NAME[[:space:]]*=[[:space:]]*"([^"]+)"[[:space:]]*$',/subexpr,/extract)
          fname=fname[-1]
        endif else status=0
      endforeach
    endif

 if file_basename(fname) eq fname then fname=file_dirname(filename,/mark_directory)+fname
 indf=file_which('cirs_index.sav',/include_current_dir)
 if indf then restore,indf,/verbose
 foreach tt,table,it do begin
   fp=tt.det eq 0 ? 1 : (tt.det gt 20 ? 4 : 3) ;CIRS focal plane number
   table[it]._conf_key=strtrim(fix(tt.det),2)+'_'+strtrim(tt.ispts,2)+'_'+strtrim(tt.iwn_start,2)+'_'+strtrim(tt.iwn_step,2)
   ;table[it]._conf_key=strtrim(fix(fp),2)+'_'+strtrim(tt.ispts,2)+'_'+strtrim(tt.iwn_start,2)+'_'+strtrim(tt.iwn_step,2)
 endforeach
 if indf then begin
  it=0L
  while it lt n_elements(table) do begin
    print,it
    w=where((cirs_index.scet_start le table[it].scet) and (cirs_index.scet_end ge table[it].scet),c)
    if c then begin
      if c eq 1 then table[it]._request=(cirs_index[w[0]]).request else begin
        tmp=cirs_index[w]
        w=where(strmatch(tmp.request,'CIRS*'),c)
        if c then tmp=tmp[w]
        w=where(strmatch(tmp.request,'*PRIME'),c)
        if c then tmp=tmp[w]
        tmp=tmp[sort(tmp.duration)]
        trequest=tmp[0].request
        tstart=tmp[0].scet_start
        tend=tmp[0].scet_end
      endelse
      v=value_locate(table.scet,tend)
      table[it:v]._request=trequest
      it=v+1
    endif
 endwhile
endif
 
 label={label:label,table:table,fname:fname}
 dim=[n_elements(table)]
 if(keyword_set(nodata)) then return, 0
 

;read variable length record file
 
 openr,lun,fname,/get_lun
 bs=0US
 count=0ULL
 foreach tt,table,it do begin
   point_lun,lun,tt.ispm
   readu,lun,bs
   tmp=fltarr(bs/4)
   readu,lun,tmp
   table[it]._ispm=ptr_new(tmp)
   table[it]._ispw=ptr_new(dindgen(bs/4)*tt.iwn_step+tt.iwn_start)
   fp=tt.det eq 0 ? 1 : (tt.det gt 20 ? 4 : 3) ;CIRS focal plane number
   table[it]._conf_key=strtrim(fix(tt.det),2)+'_'+strtrim(tt.ispts,2)+'_'+strtrim(tt.iwn_start,2)+'_'+strtrim(tt.iwn_step,2)
   ;table[it]._conf_key=strtrim(fix(fp),2)+'_'+strtrim(tt.ispts,2)+'_'+strtrim(tt.iwn_start,2)+'_'+strtrim(tt.iwn_step,2)
   readu,lun,bs
   count+=bs+4
 endforeach
 
 free_lun,lun
 label={label:label.label,table:table,fname:fname}
 dat_set_header,dd,label
 image=table.power/(table.ispts*table.iwn_step)
 type = size(image, /type)

 return, image










end
;=============================================================================
