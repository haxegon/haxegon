package haxegon.util;

import openfl.Assets;
import starling.text.*;
import starling.display.*;
import openfl.geom.*;

@:access(haxegon.Text)
class Fontclass {
	public function new(_name:String, _size:Float) {
		type = Text.fontfile[Text.fontfileindex.get(_name)].type;
		if (type == "bitmap") {
			loadbitmapfont(_name, _size);
		}else if (type == "ttf") {
			loadbitmapfont(_name, _size);
		}
	}
	
	public function loadbitmapfont(_name:String, _size:Float) {
		name = _name;
		size = _size;
		
		fontfile = Text.fontfile[Text.fontfileindex.get(_name)];
		
		tf = new TextField(Gfx.screenwidth, Gfx.screenheight, "???", fontfile.typename, fontfile.sizescale * size);
		tf.vAlign = "top";
		tf.hAlign = "left";
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
	}
	
	public var width(get, never):Float;
	
	function get_width():Float {
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		return Std.int(tf.width);
	}
	
	public var height(get, never):Float;
	
	function get_height():Float {
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		return Std.int(tf.height);
	}
	
	public var tf:TextField;
	public var fontfile:Fontfile;
	
	public var name:String;
	public var type:String;
	public var size:Float;
}