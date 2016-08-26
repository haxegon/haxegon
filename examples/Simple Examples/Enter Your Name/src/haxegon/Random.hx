package haxegon;

class Random{
	/** Return a random boolean value (true or false) */
	#if haxegonweb
	public static function bool():Bool{
	#else
	public static inline function bool():Bool{
	#end
		return random() < 0.5;
	}
	
	/** True 1/5th of the time */
	#if haxegonweb
	public static function occasional():Bool{
	#else
	public static inline function occasional():Bool{
	#end
		return random() < 0.2;
	}

	/** True 5% or 1/20th of the time */
	#if haxegonweb
	public static function rare():Bool{
	#else
	public static inline function rare():Bool{
	#end
		return random() < 0.05;
	}
	
	/** Returns true n% of the time, where n is a number between 0-100, inclusive. */
	#if haxegonweb
	public static function chance(n:Int):Bool{
	#else
	public static inline function chance(n:Int):Bool{
	#end
		return int(0, 100) <= n;
	}
	
	/** Return a random integer between 'from' and 'to', inclusive. */
	#if haxegonweb
	public static function int(from:Int, to:Int):Int {
	#else
	public static inline function int(from:Int, to:Int):Int {
	#end
		return from + Math.floor(((to - from + 1) * random()));
	}
	
	/** Return a random float between 'from' and 'to', inclusive. */
	#if haxegonweb
	public static function float(from:Float, to:Float):Float{
	#else
	public static inline function float(from:Float, to:Float):Float{
	#end
		return from + ((to - from) * random());
	}
	
	@:generic
	public static function shufflearray<T>(arr:Array<T>) {
		var tmp:T, j:Int, i:Int = arr.length;
		while (--i > 0) {
			j = Random.int(0, i);
			tmp = arr[i];
			arr[i] = arr[j];
			arr[j] = tmp;
		}
	}

	/** Return a random string of a certain length.  You can optionally specify 
	    which characters to use, otherwise the default is (a-zA-Z0-9) */
	public static function string(length:Int, ?charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String{
		var str = "";
		for (i in 0...length){
			str += charactersToUse.charAt(int(0, charactersToUse.length - 1));
		}
		return str;
	}

	/** Return a random string from a list of up to 12 strings. */
	public static function pickstring(s1:String, s2:String, ?s3:String, ?s4:String,
																					 ?s5:String, ?s6:String, ?s7:String, ?s8:String,
																					 ?s9:String, ?s10:String, ?s11:String, ?s12:String):String{
	  temp = 2;
		if (s3 != null) temp = 3;
	  if (s4 != null) temp = 4;
	  if (s5 != null) temp = 5;
	  if (s6 != null) temp = 6;
	  if (s7 != null) temp = 7;
	  if (s8 != null) temp = 8;
	  if (s9 != null) temp = 9;
	  if (s10 != null) temp = 10;
	  if (s11 != null) temp = 11;
	  if (s12 != null) temp = 12;
		
		switch(int(1, temp)) {
			case 1: return s1;
			case 2: return s2;
			case 3: return s3;
			case 4: return s4;
			case 5: return s5;
			case 6: return s6;
			case 7: return s7;
			case 8: return s8;
			case 9: return s9;
			case 10: return s10;
			case 11: return s11;
			case 12: return s12;
		}
		
		return s1;
	}
	
	/** Return a random Int from a list of up to 12 Ints. */
	public static function pickint(s1:Int, s2:Int, ?s3:Int, ?s4:Int,
																					 ?s5:Int, ?s6:Int, ?s7:Int, ?s8:Int,
																					 ?s9:Int, ?s10:Int, ?s11:Int, ?s12:Int):Int{
	  temp = 2;
    if (s3 != null) temp = 3;
	  if (s4 != null) temp = 4;
	  if (s5 != null) temp = 5;
	  if (s6 != null) temp = 6;
	  if (s7 != null) temp = 7;
	  if (s8 != null) temp = 8;
	  if (s9 != null) temp = 9;
	  if (s10 != null) temp = 10;
	  if (s11 != null) temp = 11;
	  if (s12 != null) temp = 12;
		
		switch(int(1, temp)) {
			case 1: return s1;
			case 2: return s2;
			case 3: return s3;
			case 4: return s4;
			case 5: return s5;
			case 6: return s6;
			case 7: return s7;
			case 8: return s8;
			case 9: return s9;
			case 10: return s10;
			case 11: return s11;
			case 12: return s12;
		}
		
		return s1;
	}
	
	/** Return a random Float from a list of up to 12 Floats. */
	public static function pickfloat(s1:Float,  s2:Float, ?s3:Float, ?s4:Float,
																					 ?s5:Float, ?s6:Float, ?s7:Float, ?s8:Float,
																					 ?s9:Float, ?s10:Float, ?s11:Float, ?s12:Float):Float{
	  temp = 2;
    if (s3 != null) temp = 3;
	  if (s4 != null) temp = 4;
	  if (s5 != null) temp = 5;
	  if (s6 != null) temp = 6;
	  if (s7 != null) temp = 7;
	  if (s8 != null) temp = 8;
	  if (s9 != null) temp = 9;
	  if (s10 != null) temp = 10;
	  if (s11 != null) temp = 11;
	  if (s12 != null) temp = 12;
		
		switch(int(1, temp)) {
			case 1: return s1;
			case 2: return s2;
			case 3: return s3;
			case 4: return s4;
			case 5: return s5;
			case 6: return s6;
			case 7: return s7;
			case 8: return s8;
			case 9: return s9;
			case 10: return s10;
			case 11: return s11;
			case 12: return s12;
		}
		
		return s1;
	}
	
	public static function pick<T>(arr:Array<T>):T {
		return arr[int(0, arr.length - 1)];
	}
	
  public static function random():Float {
		seed = (seed * 16807) % 2147483647; 
		return Math.abs(seed/2147483647);
	}
	
	public static function setseed(s:Int) {
		seed = Std.int(Math.abs(s % 2147483647));
		Math.random();
	}
	
	private static var temp:Int;
	public static var seed:Int = 0;
}