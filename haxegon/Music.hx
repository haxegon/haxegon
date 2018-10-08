package haxegon;

@:access(haxegon.Audio)
class Music{
	private static function init(){
		musicaudio = null;
		autoduck = 1.0;
	}
	
	public static function play(soundname:String, fadeintime:Float = 0, loop:Bool = true, volume:Float = 1.0, panning:Float = 0){
		soundname = soundname.toLowerCase();
		
		var musiccurrentlyplaying:Bool = isplaying();
		
		if (musiccurrentlyplaying){
			musicaudio.stop(crossfade);
		}
		
		musicaudio = new Audio(soundname);
		musicaudio.loop = loop;
		musicaudio.volume = volume;
		musicaudio.panning = panning;
		if (musiccurrentlyplaying){
			musicaudio.play(Math.max(fadeintime, crossfade));
		}else{
			musicaudio.play(fadeintime);
		}
		_name = soundname;
	}
	
	public static function stop(fadeout:Float = 0){
		if (isplaying()){
			musicaudio.stop(fadeout);
		}
	}
	
	public static var crossfade:Float = 0;
	private static var musicaudio:Audio;
	
	public static function isplaying():Bool{
		var musiccurrentlyplaying:Bool = true;
		
		if (musicaudio == null){
			musiccurrentlyplaying = false;
		}else{
		  if (!musicaudio.isplaying()){
				musiccurrentlyplaying = false;
				musicaudio.dispose();
				musicaudio = null;
			}
		}
		
		return musiccurrentlyplaying;
	}
	
	public static function duck(ducklevel:Float, ducktime:Float){
		if (isplaying()){
			musicaudio.duck(ducklevel, ducktime);
		}
	}
	
	public static var autoduck:Float;
	
	public static var length(get, null):Float;
	static function get_length():Float {
		if (isplaying()){
			return musicaudio.length; 
		}
		return 0;
	}
	
	public static var position(get, set):Float;
	static function get_position():Float {
		if (isplaying()){
			return musicaudio.position; 
		}
		return 0;
	}
	
	static function set_position(newposition:Float):Float {
		if (isplaying()){
			return musicaudio.position = newposition; 
		}
		return newposition;
	}
	
	public static var name(get, set):String;
	private static var _name:String;
	static function get_name():String {
		if (musicaudio != null){
			if (musicaudio.isplaying()){
				return musicaudio.name;
			}
		}
		
		_name = "";
		return _name;
	}
	
	static function set_name(newsong:String):String{
		play(newsong);
		
		return newsong;
	}
	
	public static var volume(get, set):Float;
	private static var _volume:Float = 1.0;
	static function get_volume():Float { return _volume; }
	
	static function set_volume(newvol:Float):Float{
		_volume = newvol;
		musicaudio.volume = _volume;
		return _volume;
	}
	
	public static var panning(get, set):Float;
	private static var _panning:Float = 0;
	static function get_panning():Float { return _panning; }
	
	static function set_panning(newpanning:Float):Float{
		_panning = newpanning;
		musicaudio.panning = _panning;
		return _panning;
	}
}