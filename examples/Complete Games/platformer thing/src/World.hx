class World {
	public static var tilewidth:Int;
	public static var tileheight:Int;
	public static var mapwidth:Int;
	public static var mapheight:Int;
	
	public static var currentlevel:Array<Int>;
	public static var tilecollision:Array<Bool>;
	
	public static function init():Void {
		//Some useful constants:
		tilewidth = 16; tileheight = 16;
		mapwidth = 24; mapheight = 15;
		
		tilecollision = [];
		for (i in 0 ... 100) {
			tilecollision.push(false);
		}
		
		tilecollision[1] = true;
	}
	
	public static function tileat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < mapwidth && y < mapheight) {
			return currentlevel[x + (y * mapwidth)];
		}
		return -1;
	}
}