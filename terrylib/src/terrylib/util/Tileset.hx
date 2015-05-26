package terrylib.util;

import openfl.display.*;

class Tileset {
	public function new(n:String, w:Int, h:Int) {
		name = n;
		width = w;
		height = h;
	}
	
	public var tiles:Array<BitmapData> = new Array<BitmapData>();
	public var name:String;
	public var width:Int;
	public var height:Int;
}