;=============================================================================
;+
; NAME:
;       findfile0
;
;
; PURPOSE:
;       Same as findfile, but expands the '~' symbol..
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = findfile0(filespec)
;
;
; ARGUMENTS:
;  INPUT:
;       filespec:       A filename that may contain the ~ symbol.
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of found filenames.
;
; PROCEDURE:
;       Every occurrence of '~' is replaced by '$HOME' before calling findfile.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale  8/2012
;
;-
;=============================================================================
function findfile0, _filespec

 filespec = strep_s(_filespec, '~', '$HOME')

 return, findfile(filespec)
end
;=============================================================================
