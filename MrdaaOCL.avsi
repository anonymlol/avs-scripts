/*
Modified version of mandarinka's MrdaaLame (http://forum.doom9.org/showthread.php?t=167480)
Based on Daa: Anti-aliasing with contra-sharpening by Didée, modded by Terranigma for nnedi and by thetoof for merge
*/

function MrdaaOCL(clip c, float "resharpen") {

    resharpen = Default(resharpen, 0)

    dbl          = c.nnedi3x(field=1, dh=true, dw=1).Spline36Resize(c.width,c.height,-0.5,-0.5,c.width*2,c.height*2)
    dblD         = mt_makediff(c,dbl,U=3,V=3)
    shrpD        = mt_makediff(dbl,dbl.blur(resharpen*0.2,MMX=false),U=3,V=3)
    DD           = shrpD.repair(dblD,13)
    
    return dbl.mt_adddiff(DD,U=3,V=3) 
}