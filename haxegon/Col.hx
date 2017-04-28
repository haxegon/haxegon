package haxegon;

//From Arne's legendary 16 colour palette: http://androidarts.com/palette/16pal.htm

class Col {
	public static var BLACK:Int = 0x000000;
	public static var GREY:Int = 0x9D9D9D;
	public static var GRAY:Int = 0x9D9D9D;
	public static var WHITE:Int = 0xFFFFFF;
	public static var RED:Int = 0xBE2633;
	public static var PINK:Int = 0xE06F8B;
	public static var DARKBROWN:Int = 0x493C2B;
	public static var BROWN:Int = 0xA46422;
	public static var ORANGE:Int = 0xEB8931;
	public static var YELLOW:Int = 0xF7E26B;
	public static var DARKGREEN:Int = 0x2F484E;
	public static var GREEN:Int = 0x44891A;
	public static var LIGHTGREEN:Int = 0xA3CE27;
	public static var NIGHTBLUE:Int = 0x1B2632;
	public static var DARKBLUE:Int = 0x005784;
	public static var BLUE:Int = 0x31A2F2;
	public static var LIGHTBLUE:Int = 0xB2DCEF;
	public static var MAGENTA:Int = 0xFF00FF;
	
	public static var TRANSPARENT:Int = 0x000001;
	
	public static inline function getred(c:Int):Int {
		return ((c >> 16) & 0xFF);
	}
	
	public static inline function getgreen(c:Int):Int {
		return ((c >> 8) & 0xFF);
	}
	
	public static inline function getblue(c:Int):Int {
		return (c & 0xFF);
	}
	
	public static inline function shiftred(c:Int, shift:Float):Int {
	  return rgb(Std.int(Geom.clamp(getred(c) + shift, 0, 255)), getgreen(c), getblue(c));
	}
	
	public static inline function shiftgreen(c:Int, shift:Float):Int {
	  return rgb(getred(c), Std.int(Geom.clamp(getgreen(c) + shift, 0, 255)), getblue(c));
	}
	
	public static inline function shiftblue(c:Int, shift:Float):Int {
	  return rgb(getred(c), getgreen(c), Std.int(Geom.clamp(getblue(c) + shift, 0, 255)));
	}
	
	public static function shifthue(c:Int, shift:Float):Int {
		if (shift < 0) {
			while (shift < 0) shift += 360;
		}
	  return hsl((gethue(c) + Std.int(shift)) % 360, getsaturation(c), getlightness(c));
	}
	
	public static function multiplysaturation(c:Int, shift:Float):Int {
		return hsl(gethue(c), Geom.clamp(getsaturation(c) * shift, 0, 1.0), getlightness(c));
	}
	
	public static function multiplylightness(c:Int, shift:Float):Int {
		return hsl(gethue(c), getsaturation(c), Geom.clamp(getlightness(c) * shift, 0, 1.0));
	}
	
	/** Get the Hue value (0-360) of a hex code colour. **/
	public static function gethue(c:Int):Int {	
    var r:Float = getred(c) / 255;
		var g:Float = getgreen(c) / 255;
		var b:Float = getblue(c) / 255;
    var max:Float = Math.max(Math.max(r, g), b); 
		var min:Float = Math.min(Math.min(r, g), b); 
    
		var h:Float = (max + min) / 2;
		
    if (max != min) {
			var d:Float = max - min;
			if(max == r){
				h = (g - b) / d + (g < b ? 6 : 0);
			}else if (max == g) {
				h = (b - r) / d + 2;
			}else if (max == b) {
				h = (r - g) / d + 4;
			}
			h /= 6;
    }
		
    return Std.int(h * 360);
	}
	
	/** Get the Saturation value (0.0-1.0) of a hex code colour. **/
	public static function getsaturation(c:Int):Float {
    var r:Float = getred(c) / 255;
		var g:Float = getgreen(c) / 255;
		var b:Float = getblue(c) / 255;
    var max:Float = Math.max(Math.max(r, g), b); 
		var min:Float = Math.min(Math.min(r, g), b); 
    
		var s:Float = (max + min) / 2;
		var l:Float = s;
		
    if (max == min) {
			s = 0;
    }else {
			var d:Float = max - min;
			s = l > 0.5?d / (2 - max - min):d / (max + min);
    }
		
    return s;
	}
	
	/** Get the Lightness value (0.0-1.0) of a hex code colour. **/
	public static function getlightness(c:Int):Float {
		var r:Float = getred(c) / 255;
		var g:Float = getgreen(c) / 255;
		var b:Float = getblue(c) / 255;
    var max:Float = Math.max(Math.max(r, g), b); 
		var min:Float = Math.min(Math.min(r, g), b); 
		
    return (max + min) / 2;
	}
	
	public static function rgb(red:Int, green:Int, blue:Int):Int {
		return (blue | (green << 8) | (red << 16));
	}
	
	/** Picks a colour given Hue, Saturation and Lightness values. 
	 *  Hue is between 0-359, Saturation and Lightness between 0.0 and 1.0. */
	public static function hsl(hue:Float, saturation:Float, lightness:Float):Int {
		var q:Float = if (lightness < 1 / 2) {
			lightness * (1 + saturation);
		}else {
			lightness + saturation - (lightness * saturation);
		}
		
		var p:Float = 2 * lightness - q;
		
		var hk:Float = ((hue % 360) / 360);
		
		hslval[0] = hk + 1 / 3;
		hslval[1] = hk;
		hslval[2] = hk - 1 / 3;
		for (n in 0 ... 3){
			if (hslval[n] < 0) hslval[n] += 1;
			if (hslval[n] > 1) hslval[n] -= 1;
			hslval[n] = if (hslval[n] < 1 / 6){
				p + ((q - p) * 6 * hslval[n]);
			}else if (hslval[n] < 1 / 2)	{
				q;
			}else if (hslval[n] < 2 / 3){
				p + ((q - p) * 6 * (2 / 3 - hslval[n]));
			}else{
				p;
			}
		}
		
		return rgb(Std.int(hslval[0] * 255), Std.int(hslval[1] * 255), Std.int(hslval[2] * 255));
	}
	//HSL conversion variables 
	private static var hslval:Array<Float> = [0.0, 0.0, 0.0];
}