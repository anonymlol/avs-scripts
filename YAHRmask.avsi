/*

YAHR, Y'et A'nother H'alo R'educing script, by Didée, http://avisynth.nl/index.php/YAHR
YAHRmask, by Tophf, http://pastebin.com/hxWHpspK
With slight modifications (merging both functions into one). Output should be identical.

*/

function YAHRmask(clip input, int "expand", int "warpdepth") {

	expand    = Default(expand, 5)
	warpdepth = Default(warpdepth, 32)
    
	b1    = input.minblur(2).removegrain(12, -1)
	b1D   = mt_makediff(input, b1)
	w1    = input.aWarpSharp2(depth=warpdepth, blur=2)
	w1b1  = w1.minblur(2, 1).removegrain(11, -1)
	w1b1D = mt_makediff(w1, w1b1)
	DD    = b1D.repair(w1b1D, 13)
	DD2   = mt_makediff(b1D, DD)
    yahr  = input.mt_makediff(DD2, U=2, V=2)
    
    input
	vEdge = mt_lutxy(last, mt_expand().mt_expand(),"x y - abs 8 - 7 <<")
	
    mt_merge(yahr, vEdge.binomialblur(expand*2, u=1, v=1)
    \ .mt_lut("x 4 <<")
    \ .mt_logic(vEdge.removegrain(12, -1)
    \ .mt_invert(), "min"), true)
}