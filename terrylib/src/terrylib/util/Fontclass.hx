package terrylib.util;

import openfl.Assets;
import openfl.text.*;
import openfl.display.*;

class Fontclass {
	public function new(_name:String, _size:Int) {
		name = _name;
		size = _size;
		
		tf = new TextField();
		tf.embedFonts = true;
		tf.defaultTextFormat = new TextFormat(Text.getfonttypename(_name), size, 0, false);
		tf.selectable = false;
		tf.width = Gfx.screenwidth; 
		tf.height = Gfx.screenheight;
		if (size <= 16) {
			tf.antiAliasType = AntiAliasType.ADVANCED; //Small fonts need proper antialiasing
		}else {
		  tf.antiAliasType = AntiAliasType.NORMAL;	
		}
		
		
		tf.text = "???";
		tfbitmap = new BitmapData(Gfx.screenwidth, Std.int(tf.textHeight)*2, true, 0);
		tf.height = tf.textHeight * 2;
	}
	
	public function clearbitmap():Void {
		tfbitmap.fillRect(tfbitmap.rect, 0);
	}
	
	public var tf:TextField;
	public var tfbitmap:BitmapData;
	
	public var name:String;
	public var size:Int;
}