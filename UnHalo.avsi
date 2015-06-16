/*
UnHalo
=======

Based on a script from BakaProxy.

Requirements:
    * YAHRmask
    * TCannyMod
    * MaskTools2
    * HQDering mod
    * f3kdb
    * nnedi3ocl
    
Parameters:
    + [string] dark_str ("1.5")
        *   Darkening strength. Sensible values: 1-4
    + [bool] HQ (true)
        *   Enlarges the frame with nnedi3x_rpow2. Gives a cleaner output.
*/

function UnHalo(clip input, string "dark_str", bool "HQ") {

    dark_str   = Default(dark_str, "1.5")
    HQ         = Default(HQ, true)
    
    ix = input.width()
    iy = input.height()
    
    input       = HQ == true ? input.nnedi3x_rpow2(rfactor=2, cshift="spline16resize") : input
    dmask       = input.TCannyMod(sigma=1).mt_expand().mt_expand().mt_expand()
    avg         = input.AverageBlur(radY=3)
    mk          = mt_lutxy(input,mt_merge(input,avg,dmask),"x y min x - 0 < x y min x y x min - " + dark_str + " / + x y min ?")
    dering      = mk.hqderingmod(mrad=2,nrmode=2)
    yahrm       = dering.yahrmask(13,48) #all of above is to get rid of the halos    
    fixchrblock = yahrm.f3kdb(15,30,50,50,0,0) #fixing chroma blocking
    output_res  = HQ == true ? fixchrblock.spline16resize(ix, iy) : fixchrblock
    
    return output_res
}
