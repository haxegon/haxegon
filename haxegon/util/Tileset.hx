package haxegon.util;

import starling.display.*;

class Tileset {
	public function new(n:String, w:Int, h:Int) {
		name = n;
		width = w;
		height = h;
		
		tiles = [];
	}
	
	public var tiles:Array<Image>;
	public var name:String;
	public var width:Int;
	public var height:Int;
}