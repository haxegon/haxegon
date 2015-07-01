import terrylib.*;

class Game {
	//Helper function for stuff we need to access from anywhere
	public static var tilewidth:Int;
	public static var tileheight:Int;
	public static var mapwidth:Int;
	public static var mapheight:Int;
	
	public static var jumppressed:Int;
	public static var temp:Int;
	
	public static var currentlevel:Array<Int>;
	
	public static var tilecollision:Array<Bool>;
	
	public static var maxentities:Int;
	
	public static function init():Void {
		//Some useful constants:
		tilewidth = 16; tileheight = 16;
		mapwidth = 24; mapheight = 15;
		
		jumppressed = 0;
		
		maxentities = 100;
		
		tilecollision = [];
		for (i in 0 ... 100) {
			tilecollision.push(false);
		}
		
		tilecollision[1] = true;
	}
	
	public static function getgridpoint(t:Float, gridwidth:Int):Int {
		t = ((t - (t % gridwidth)) / gridwidth);
		return Convert.toint(t);
	}
	
	public static function tileat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < mapwidth && y < mapheight) {
			return currentlevel[x + (y * mapwidth)];
		}
		return -1;
	}
	
	public static function tilecollide(x:Int, y:Int):Bool {
		//Check if tile at x, y is a collision tile.
		temp = tileat(x, y);
		if (temp > -1) {
		  return tilecollision[temp];	
		}
		return true;
	}
	
	public static function pointcollide(x:Float, y:Float):Bool {
		//Check if a point collides with the map
		if (tilecollide(getgridpoint(x, tilewidth), getgridpoint(y, tileheight))) return true;
		return false;
	}
	
	public static function checkwall(x:Float, y:Float, w:Float, h:Float):Bool {
		//Check key points in the rectangle to see if there's a collision.
		//Corners
		if (pointcollide(x, y)) return true;
		if (pointcollide(x + w - 1, y)) return true;
		if (pointcollide(x, y + h - 1)) return true;
		if (pointcollide(x + w - 1, y + h - 1)) return true;
		
		//Half way points
		if (pointcollide(x + 8, y)) return true;
		if (pointcollide(x + 8, y + h - 1)) return true;
		if (pointcollide(x, y + 8)) return true;
		if (pointcollide(x + w - 1, y + 8)) return true;
		
		return false;
	}
}