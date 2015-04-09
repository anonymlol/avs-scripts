/*
Based on mandarinka's script: http://forum.doom9.org/showthread.php?p=1541058#post1541058
with snippets from TemporalDegrain()
*/

function GlutenFree(clip last, int "bright", int "dark", string "lut", bool "ProtectDark", bool "ContraSharp", bool "GPU") {

    bright      = Default(bright, 130)        # Degrain strength for bright areas, higher is stronger.
    dark        = Default(dark, 50)           # Degrain strength for dark areas, higher is stronger.
    lut         = Default(lut, "40000")       # Decrease for stronger degraining.
    ProtectDark = Default(ProtectDark, false) # "True" degrains dark areas less to protect details. False doesn't.
    ContraSharp = Default(ContraSharp, false)  # Sharpen the denoised clip, but don't add more than what was removed previously.
    GPU         = Default(GPU, true)          # GPU or CPU for degraining prefilter
    
    source          = last
    hw              = (GPU) ? FFT3Dgpu(sigma=2.5,bw=32,bh=32,bt=3,ow=16,oh=16,plane=4,precision=1) 
                          \ : FFT3DFilter(sigma=2.5,bw=32,bh=32,bt=3,ow=16,oh=16,plane=4)
    prefilt         = hw  # prefiltering the ME source for better accuracy or something
    superfilt       = prefilt.MSuper(pel=2, sharp=1)
    super           = MSuper(pel=2, sharp=1)
    backward_vec2   = MAnalyse(superfilt, isb=true, delta=2, overlap=4)
    backward_vec1   = MAnalyse(superfilt, isb=true, delta=1, overlap=4)
    forward_vec1    = MAnalyse(superfilt, isb=false, delta=1, overlap=4)
    forward_vec2    = MAnalyse(superfilt, isb=false, delta=2, overlap=4)
    degrain         = source.MDegrain2(super, backward_vec1,forward_vec1,backward_vec2,forward_vec2,thSAD=bright)
    mask            = source.mt_lut("x 3.10 ^ "+ lut +" /")
    degrainless     = source.MDegrain2(super, backward_vec1,forward_vec1,backward_vec2,forward_vec2,thSAD=dark)
    ProtectDark     = (ProtectDark) ? source : degrainless
    NR2             = mt_merge(ProtectDark,degrain,mask,luma=true) # or swap degrainless for source if you want almost no touching of dark parts
    
    # Contra-sharpening: sharpen the denoised clip, but don't add more than what was removed previously.
    # Here: A simple area-based version with relaxed restriction. The full version is more complicated.
    s      = NR2.minblur(1,1)                    # Damp down remaining spots of the denoised clip.
    allD   = mt_makediff(source,NR2)             # The difference achieved by the denoising.
    ssD    = mt_makediff(s,s.removegrain(11,-1)) # The difference of a simple kernel blur.
    ssDD   = ssD.repair(allD,1)                  # Limit the difference to the max of what the denoising removed locally.
    ssDD   = ssDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?") # abs(diff) after limiting may not be bigger than before.

    NR2_sharp = NR2.mt_adddiff(ssDD,U=2,V=2) # Apply the limited difference. (Sharpening is just inverse blurring.)

    output = (ContraSharp) ? NR2_sharp : NR2
    return output
}