package haxegon;

import openfl.geom.Rectangle;

class Geom {
	public static inline var PI:Float = 3.141592653589793;
	public static inline function abs(v:Float):Float{ return Math.abs(v); }
	public static inline function acos(v:Float):Float{ return todegrees(Math.acos(v)); }
	public static inline function asin(v:Float):Float{ return todegrees(Math.asin(v)); }
	public static inline function atan(v:Float):Float{ return todegrees(Math.atan(v)); }
	public static inline function atan2(y:Float, x:Float):Float{ return todegrees(Math.atan2(y, x)); }
	public static inline function ceil(v:Float):Float{ return Math.ceil(v); }
	public static inline function cos(v:Float):Float{ return Math.cos(toradians(v)); }
	public static inline function exp(v:Float):Float{ return Math.exp(v); }
	public static inline function floor(v:Float):Float{ return Math.floor(v); }
	public static inline function fround(v:Float):Float{ return Math.fround(v); }
	public static inline function log(v:Float):Float{ return Math.log(v); }
	public static inline function max(a:Float, b:Float):Float{ return Math.max(a, b); }
	public static inline function min(a:Float, b:Float):Float{ return Math.min(a, b); }
	public static inline function pow(v:Float, exp:Float):Float{ return Math.pow(v, exp); }
	public static inline function round(v:Float):Float{ return Math.round(v); }
	public static inline function sin(v:Float):Float{ return Math.sin(toradians(v)); }
	public static inline function sqrt(v:Float):Float{ return Math.sqrt(v); }
	public static inline function tan(v:Float):Float{ return Math.tan(toradians(v)); }
	
  public static function inbox(x:Float, y:Float, rectx:Float, recty:Float, rectw:Float, recth:Float):Bool {
	  if (x >= rectx) {
			if (x < rectx + rectw) {
				if (y >= recty) {
					if (y < recty + recth) {
						return true;
					}
				}
			}
		}
		return false;
	}
	
	public static inline function clamp(value:Float, min:Float, max:Float):Float {
	  return Math.min(max, Math.max(value, min));
	}
	
	public static function overlap(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool {
		rect1.setTo(x1, y1, w1, h1);
		rect2.setTo(x2, y2, w2, h2);
		
		return rect1.intersects(rect2);
	}
	
	public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
	}
	
	public static inline function getangle(x1:Float, y1:Float, x2:Float, y2:Float):Float {
    return todegrees(((Math.PI * 2) - Math.atan2(y2 - y1, x2 - x1)) % (Math.PI * 2));
  }
	
	public static inline function todegrees(rad:Float):Float {
		return ((rad * 180) / Math.PI);
	}
	
	public static inline function toradians(degrees:Float):Float {
		return ((degrees * Math.PI) / 180);
	}
	
	public static inline function anglebetween(angle1:Float, angle2:Float):Float {
		return -atan2(sin(angle1 - angle2), cos(angle1 - angle2));
	}

	public static inline function lerp(value:Float, target:Float, f:Float):Float {
		f = clamp(f, 0, 1);
		return (value + f * (target - value));
	}

	public static inline function range_lerp(value:Float, a1:Float, a2:Float, b1:Float, b2:Float):Float {
		return b1 + (value - a1) * (b2 - b1) / (a2 - a1);
	}

	public static function wrap(v:Float, min:Float, max:Float):Float {
    var range = max - min + 1;
    if (v < min) v += range * ((min - v) / range + 1);
    return clamp(min + (v - min) % range, min, max);
	}
	
	private static var rect1:Rectangle = new Rectangle();
	private static var rect2:Rectangle = new Rectangle();
}