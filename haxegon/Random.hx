//Haxegon uses an implementation of George Marsaglia's Xorshift, coded by Andrew Zhilin.
//https://gist.github.com/zoon/865342
//https://en.wikipedia.org/wiki/Xorshift
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
		return randinterval(from, to, true);
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
	
	public static function weighted<T>(options:Array<T>, odds:Array<Int>):T{
		//"weighted" is inspired by, and based on chance.js
		//http://chancejs.com/#weighted
		if (options.length != odds.length){
			trace("Error: in Random.weighted(), both arrays should be the same size.");
			trace("Returning a random option from the first array instead.");
			return pick(options);
		}
		
		var result:Int = 0;
		
		var totalodds:Int = 0;
		for (i in 0 ... odds.length) totalodds += odds[i];
		
		var r:Int = int(0, totalodds);
		
		var lastid:Int = -1;
		totalodds = 0;
		for (i in 0 ... options.length) {
			var current:Int = odds[i];
			totalodds += current;
			if (current > 0) {
				if (r <= totalodds) {
					result = i;
					break;
				}
				lastid = i;
			}
			
			if (i == (odds.length - 1)) result = lastid;
		}
		
		return options[result];
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
	
	public static var seed(get,set):Dynamic;
	private static var _seed:Dynamic = null;

	static function get_seed():Dynamic {
		return _seed;
	}

	static function set_seed(s:Dynamic) {
		if (s == null){
			_seed = Std.int(1 + Math.random() * (INT_MAX - 1));
		}else	if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(s, String)){
			if (s == ""){
				s = Date.now().toString();
			}
			
			_seed = 0;
			for (i in 0 ... s.length){
				_seed += s.charCodeAt(i) * ((i + 1) ^ 2);
			}
		}else if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(s, Int)){
			if (s == 0){
				_seed = Std.int(1 + Math.random() * (INT_MAX - 1));
			}else{
				_seed = Std.int(s);
			}
		}else{
			s = Std.string(s);
			_seed = 0;
			for (i in 0 ... s.length){
				_seed += s.charCodeAt(i) * ((i + 1) ^ 2);
			}
		}
		
		return _seed;
	}
	
	//All the following code is by Andrew Zhilin
	//See https://gist.github.com/zoon/865342
	
	public static function random():Float {
		return gen31() / INT_MAXPLUSONE;
	}
	
	/**
	 * Returns a random Int in [0, INT_MAX]
	 */
	inline private static function gen31():Int
	{
		return gen32() & INT_MAX;
	}
	
	/**
	 * Returns a random Int in [INT_MIN, 0) U (0, INT_MAX]
	 */
	inline private static function gen32():Int
	{
		_seed ^= (_seed << 13);
		_seed ^= (_seed >>> 17);
		return _seed ^= (_seed << 5);
	}
	
	/**
	 *  Return a random Int in [0, n)
	 */
	private static function rand(n:Int):Int
	{
		if (n <= 0 || n > INT_MAX)
			throw "n out of (0, INT_MAX]";
		var bucket_size = Std.int(INT_MAX / n);
		
		var r;
		do 
		{ 
			r = Std.int(gen31() / bucket_size);
		} 
		while (r >= n);
		return r;
	}
	
	/**
	 * Returns a random Int in [min, max) by dafault,
	 * or in [min, max] if includeMax == true;
	 */
	private static function randinterval(min:Int, max:Int, ?includeMax:Bool=false)
	{
		if (min == max) return min;
		if (max < min) return randinterval(max, min, includeMax);
		if (min < 0 || max < 1){
			return rand((max - min) + (includeMax ? 1 : 0)) + min;
		}
		return min + rand(max - min + (includeMax ? 1 : 0));
	}
	
	inline private static var INT_MAX:Int = 0x7FFFFFFF; // (2^31 - 1)
	inline private static var INT_MAXPLUSONE:Float = 2147483648.0;
}
