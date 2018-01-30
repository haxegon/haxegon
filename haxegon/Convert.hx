package haxegon;

class Convert {
	public static function tostring(?value:Dynamic):String {
		return Std.string(value);
	}

	public static function toint(?value:Dynamic):Int {
		if (Std.is(value, Int)){
			return value;
		}else if(Std.is(value, Float)){
			return Std.int(value);
		}
		return Std.parseInt(Std.string(value));
	}
	
	public static function tofloat(?value:Dynamic):Float {
		return Std.parseFloat(value);
	}	
}