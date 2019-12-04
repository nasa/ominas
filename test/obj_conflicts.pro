;===============================================================================
; obj_conflicts
;
;  Compile this program to test for conflicts among the object keywords.
;
;  Allowable conflicts:
;	map / cam
;	map / glb
;
;===============================================================================
pro obj_conflicts, $
        @cor__keywords.include
        @dat__keywords.include
        @pnt__keywords.include
        @map__keywords.include
        @arr__keywords.include
        @bod__keywords.include
        @cam__keywords.include
        @sld__keywords.include
        @glb__keywords.include
        @dsk__keywords.include
        @str__keywords.include
        @plt__keywords.include
        @rng__keywords.include
        @stn__keywords.include
        end_keywords

end
;===============================================================================
