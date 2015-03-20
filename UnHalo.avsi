/*
UnHalo
=======

Requirements:
    * YAHRmask
    * tcanny
    * MaskTools2
    * HQDering mod
    * f3kdb
    
Parameters:
    + [string] dark_str ("2")
        *   Darkening strength. Sensible values: 1-4
*/

function UnHalo(clip input, string "dark_str") {

    dark_str   = Default(dark_str, "1.5")
        
    dmask       = input.tcanny(sigma=1).mt_expand().mt_expand().mt_expand()
    avg         = input.AverageBlur(radY=3)
    mk          = mt_lutxy(input,mt_merge(input,avg,dmask),"x y min x - 0 < x y min x y x min - " + dark_str + " / + x y min ?")
    dering      = mk.hqderingmod(mrad=2,nrmode=2)
    yahrm       = dering.yahrmask(13,48) #all of above is to get rid of the halos    
    fixchrblock = yahrm.f3kdb(15,30,50,50,0,0) #fixing chroma blocking
    
    return fixchrblock
}
