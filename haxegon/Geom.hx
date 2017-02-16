package haxegon;

import openfl.geom.Rectangle;

class Geom {
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
    return ((Math.PI * 2) - Math.atan2(y2 - y1, x2 - x1)) % (Math.PI * 2);
  }
	
	public static inline function todegrees(rad:Float):Float {
		return ((rad * 180) / Math.PI);
	}
	
	public static inline function toradians(degrees:Float):Float {
		return ((degrees * Math.PI) / 180);
	}
	
	public static inline function anglebetween(angle1:Float, angle2:Float):Float {
		return -Math.atan2(Math.sin(angle1 - angle2), Math.cos(angle1 - angle2));
	}
	
	private static var rect1:Rectangle = new Rectangle();
	private static var rect2:Rectangle = new Rectangle();
}