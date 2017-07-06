package haxegon;

class Random{
	/** Return a random boolean value (true or false) */
	public static function bool():Bool{
		return random() < 0.5;
	}
	
	/** Returns true n% of the time, where n is a float between 0-100, inclusive. */
	public static function chance(n:Float):Bool{
		return float(0, 100) < n;
	}
	
	/** Return a random integer between 'from' and 'to', inclusive. */
	public static function int(from:Int, to:Int):Int {
		return from + Math.floor(((to - from + 1) * random()));
	}
	
	/** Return a random float between 'from' and 'to', inclusive. */
	public static function float(from:Float, to:Float):Float{
		return from + ((to - from) * random());
	}
	
	@:generic
	public static function shuffle<T>(arr:Array<T>):Array<T> {
		var tmp:T, j:Int, i:Int = arr.length;
		while (--i > 0) {
			j = Random.int(0, i);
			tmp = arr[i];
			arr[i] = arr[j];
			arr[j] = tmp;
		}
		
		return arr;
	}

	/** Return a random string of a certain length.  You can optionally specify 
	    which characters to use, otherwise the default is (a-zA-Z0-9) */
	public static function string(length:Int, ?charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String{
		var str = "";
		for (i in 0 ... length){
			str += charactersToUse.charAt(int(0, charactersToUse.length - 1));
		}
		return str;
	}

	public static function pick<T>(arr:Array<T>):T {
		return arr[int(0, arr.length - 1)];
	}
	
	public static function random():Float {
		_actualseed = (_actualseed * 16807) % 2147483647;
		return Math.abs(_actualseed / 2147483647);
	}
	
	public static var seed(get,set):Int;
	private static var _initialseed:Int = 1;
	private static var _actualseed:Int = 1;

	static function get_seed():Int {
		return _initialseed;
	}

	static function set_seed(s:Int) {
		if(s == 0) s = 1;
		_initialseed = s;
		_actualseed = Std.int(Math.abs(_initialseed % 2147483647));
		for (i in 0 ... 10) random(); //Shuffle it a few times
		return _initialseed;
	}
}
