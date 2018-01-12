package haxegon;

class Music{
	public static function play(soundname:String, offsettime:Float = 0, fadeintime:Float = 0, loop:Bool = true){
		
	}
	
	public static function stop(soundname:String = "", fadeout:Float = 0){
		
	}
	
	public static function playing():String{
		return _currentsong;
	}
	
	public static var crossfade:Bool = true;
	private static var _currentsong:String;
}