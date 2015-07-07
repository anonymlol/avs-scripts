/*
aWarpNN
=======

Requirements:
    * NNEDI3 and/or NNEDI3ocl 
    * awarpsharp2

Parameters:
    + [int] rfactor (2)
        *   Image enlargement factor. Must be a power of 2 in the range [2, 1024].
    + [int] thresh (128)
        *   Saturation limit for edge detection. Reduce for less aggressive sharpening. Range [0, 255].
    + [int] blur (1)
        *   Number of blur passes over edge mask. Less passes increase sharpening effect, but can produce major artifacts with high depth and thresh values. Range [0, 100].
    + [int] type (0)
        *   Type of blur
            *   0: radius 6 blur. 
            *   1: radius 2 blur, requires around 8x more passes than type=0 for the same effect (will be 2.5x slower), but will produce better quality.
    + [int] depth (16)
        *   Strength of the final warping. Negative values result in warping in opposite direction. Range [-128, 127]
    + [int] chroma (4)
        *   Processing mode for chroma planes (U and V)
            *   0: fill with zeros
            *   1: don't care
            *   2: copy
            *   3: process
            *   4: guide by luma
            *   5: same as 3, but don't process luma
            *   6: same as 4, but don't process luma
    + [bool] resize (true)
        *   Resize back to input resolution.
    + [string] resizer (spline36)
        *   Resizer for downscaling. Possible resizers listed below.
    + [bool] OpenCL (true)
        *   NNEDI3ocl instead of NNEDI3.
*/

function aWarpNN(clip input, int "rfactor", int "thresh", int "blur", int "type", int "depth", int "chroma", bool "resize" ,string "resizer", bool "OpenCL") {

    rfactor = Default(rfactor, 2) 
    thresh  = Default(thresh, 128) 
    blur    = Default(blur, 1) 
    type    = Default(type, 0) 
    depth   = Default(depth, 16) 
    chroma  = Default(chroma, 4)
    resize  = Default(resize, true)
    resizer = Default(resizer, "spline36")
    OpenCL  = Default(OpenCl, true)
    
    ix    = input.width()
    iy    = input.height()
    
    rpowX = (OpenCL) ? nnedi3x_rpow2(input, rfactor, cshift="spline16resize")
                   \ : nnedi3_rpow2(input, rfactor, cshift="spline16resize")
                   
    sharp = aWarpSharp2(rpowX, thresh, blur, type, depth, chroma)
    
    res   = (resizer == "spline16"  || resizer == "spline16resize" ) ?  Spline16Resize(sharp, ix, iy)   
        \ : (resizer == "spline36"  || resizer == "spline36resize" ) ?  Spline36Resize(sharp, ix, iy)  
        \ : (resizer == "spline64"  || resizer == "spline64resize" ) ?  Spline64Resize(sharp, ix, iy)  
        \ : (resizer == "spline144" || resizer == "spline144resize") ? Spline144Resize(sharp, ix, iy) 
        \ : (resizer == "Bicubic"   || resizer == "BicubicResize"  ) ?   BicubicResize(sharp, ix, iy)   
        \ : (resizer == "Bilinear"  || resizer == "BilinearResize" ) ?  BilinearResize(sharp, ix, iy)  
        \ : (resizer == "Blackman"  || resizer == "BlackmanResize" ) ?  BlackmanResize(sharp, ix, iy)  
        \ : (resizer == "Gauss"     || resizer == "GaussResize"    ) ?     GaussResize(sharp, ix, iy)     
        \ : (resizer == "Lanczos"   || resizer == "LanczosResize"  ) ?   LanczosResize(sharp, ix, iy)  
        \ : (resizer == "Lanczos4"  || resizer == "Lanczos4Resize" ) ?  Lanczos4Resize(sharp, ix, iy)  
        \ : (resizer == "Point"     || resizer == "PointResize"    ) ?     PointResize(sharp, ix, iy)     
        \ : (resizer == "Sinc"      || resizer == "SincResize"     ) ?      SincResize(sharp, ix, iy)      
        \ : MessageClip("Resizer not supported")
                    
    output = (resize) ? res : sharp
    
    return output
}
